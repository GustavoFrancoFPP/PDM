import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/categoria_visual.dart';
import '../widgets/local_form.dart';
import '../widgets/transicao_tela.dart';
import 'detalhes_screen.dart';
import 'resultados_screen.dart';

class MapaScreen extends StatefulWidget {
  final double? focusLatitude;
  final double? focusLongitude;
  final String? focusNome;

  const MapaScreen({
    super.key,
    this.focusLatitude,
    this.focusLongitude,
    this.focusNome,
  });

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _pesquisaController = TextEditingController();
  final LocalService _service = LocalService();
  StreamSubscription<List<Local>>? _locaisSubscription;

  String _cidadeSelecionada = 'São Paulo';
  List<Local> _locais = [];
  bool _satelite = false;
  bool _erroMapa = false;
  int _tentativasMapa = 0;
  bool _modoAdicionar = false; // ativado para tocar no mapa e criar local

  static const Map<String, LatLng> _cidadeCentros = {
    'São Paulo': LatLng(-23.5505, -46.6333),
    'Campinas': LatLng(-22.9035, -47.0623),
    'Jundiaí': LatLng(-23.1864, -46.8964),
  };

  // URLs dos tiles
  static const _urlSatelite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const _urlSateliteOverlay =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';
  static const _urlRua =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}';
  static const _userAgent = 'br.senai.gustavofranco.mapadelocais';

  @override
  void initState() {
    super.initState();
    _locaisSubscription = _service.listarLocais().listen((locais) {
      if (mounted) setState(() => _locais = locais);
    });
  }

  @override
  void dispose() {
    _locaisSubscription?.cancel();
    _pesquisaController.dispose();
    super.dispose();
  }

  void _moverParaCidade(String cidade) {
    setState(() => _cidadeSelecionada = cidade);
    final centro = _cidadeCentros[cidade];
    if (centro != null) _mapController.move(centro, 13);
  }

  void _tentarCarregarMapa() {
    setState(() {
      _erroMapa = false;
      _tentativasMapa++;
    });
  }

  void _mostrarErroMapa() {
    if (!mounted || _erroMapa) return;
    setState(() => _erroMapa = true);
  }

  Future<void> _abrirFormulario({Local? local, LatLng? posicao}) async {
    // Sai do modo de adição ao abrir o formulário.
    if (_modoAdicionar) setState(() => _modoAdicionar = false);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => LocalForm(
        local: local,
        latitudePinada: posicao?.latitude,
        longitudePinada: posicao?.longitude,
        cidadeSugerida: _cidadeSelecionada,
        onSalvar: (localSalvo) async {
          final nav = Navigator.of(sheetContext);
          try {
            if (local == null) {
              await _service.adicionar(localSalvo);
            } else {
              await _service.atualizar(localSalvo.copyWith(id: local.id));
            }
            if (nav.mounted) nav.pop();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    local == null
                        ? 'Local cadastrado com sucesso!'
                        : 'Local atualizado com sucesso!',
                  ),
                ),
              );
            }
          } catch (e) {
            if (nav.mounted) nav.pop();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar: $e')),
              );
            }
          }
        },
      ),
    );
  }

  // Locais com coordenadas quase iguais ficariam empilhados no mapa,
  // então distribui esses marcadores em espiral ao redor do ponto.
  Map<Local, LatLng> _posicoesMarcadores(List<Local> locais) {
    final grupos = <String, List<Local>>{};
    for (final local in locais) {
      final chave =
          '${local.latitude.toStringAsFixed(3)},${local.longitude.toStringAsFixed(3)}';
      grupos.putIfAbsent(chave, () => []).add(local);
    }

    final posicoes = <Local, LatLng>{};
    for (final grupo in grupos.values) {
      if (grupo.length == 1) {
        final l = grupo.first;
        posicoes[l] = LatLng(l.latitude, l.longitude);
        continue;
      }
      final base = grupo.first;
      for (var i = 0; i < grupo.length; i++) {
        final raio = 0.0018 * sqrt(i + 1);
        final angulo = i * 2.39996; // ângulo de ouro, evita sobreposição
        posicoes[grupo[i]] = LatLng(
          base.latitude + raio * sin(angulo),
          base.longitude + raio * cos(angulo),
        );
      }
    }
    return posicoes;
  }

  List<Local> get _locaisFiltrados {
    final texto = _pesquisaController.text.toLowerCase();
    if (texto.isEmpty) return _locais;

    return _locais.where((local) {
      return local.nome.toLowerCase().contains(texto) ||
          local.categoria.toLowerCase().contains(texto);
    }).toList();
  }

  void _recentralizar() {
    if (widget.focusLatitude != null) {
      _mapController.move(
        LatLng(widget.focusLatitude!, widget.focusLongitude!),
        16,
      );
    } else {
      _mapController.move(_cidadeCentros[_cidadeSelecionada]!, 13);
    }
  }

  void _alternarModoAdicionar() {
    setState(() => _modoAdicionar = !_modoAdicionar);
  }

  void _abrirResultados({String pesquisa = ''}) {
    Navigator.push<void>(
      context,
      criarRota(
        ResultadosScreen(cidade: _cidadeSelecionada, pesquisa: pesquisa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posicaoInicial = widget.focusLatitude != null
        ? LatLng(widget.focusLatitude!, widget.focusLongitude!)
        : _cidadeCentros[_cidadeSelecionada]!;
    final cs = Theme.of(context).colorScheme;
    final total = _locaisFiltrados.length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCabecalho(),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: posicaoInicial,
                      initialZoom: widget.focusLatitude != null ? 16 : 13,
                      minZoom: 4,
                      maxZoom: 18,
                      backgroundColor: const Color(0xFFE8EFEA),
                      onMapReady: () {
                        if (widget.focusLatitude != null) {
                          _mapController.move(posicaoInicial, 16);
                        }
                      },
                      // Toque no mapa: abre formulário com posição selecionada.
                      onTap: (tapPosition, latLng) {
                        if (_modoAdicionar) {
                          _abrirFormulario(posicao: latLng);
                        }
                      },
                    ),
                    children: [
                      // Camada base: satélite ou rua
                      if (_satelite) ...[
                        TileLayer(
                          key: ValueKey('satelite-$_tentativasMapa'),
                          urlTemplate: _urlSatelite,
                          userAgentPackageName: _userAgent,
                          maxZoom: 18,
                          errorTileCallback: (tile, error, stackTrace) =>
                              _mostrarErroMapa(),
                        ),
                        // Nomes de ruas sobre as imagens de satélite
                        TileLayer(
                          key: ValueKey('satelite-overlay-$_tentativasMapa'),
                          urlTemplate: _urlSateliteOverlay,
                          userAgentPackageName: _userAgent,
                          maxZoom: 18,
                          errorTileCallback: (tile, error, stackTrace) =>
                              _mostrarErroMapa(),
                        ),
                      ] else
                        TileLayer(
                          key: ValueKey('rua-$_tentativasMapa'),
                          urlTemplate: _urlRua,
                          userAgentPackageName: _userAgent,
                          maxZoom: 18,
                          maxNativeZoom: 19,
                          errorTileCallback: (tile, error, stackTrace) =>
                              _mostrarErroMapa(),
                        ),
                      MarkerLayer(
                        markers: _posicoesMarcadores(_locaisFiltrados)
                            .entries
                            .map((e) => _marcador(e.key, e.value))
                            .toList(),
                      ),
                      // Marca o local aberto pela ação "Ver no mapa".
                      if (widget.focusLatitude != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                widget.focusLatitude!,
                                widget.focusLongitude!,
                              ),
                              width: 52,
                              height: 52,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 44,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      // Atribuição obrigatória para os tiles do mapa.
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            _satelite
                                ? 'Esri, Maxar, Earthstar Geographics'
                                : 'Sources: Esri, HERE, Garmin, USGS, Intermap, '
                                    'INCREMENT P, NRCan, Esri Japan, METI, '
                                    'Esri China (Hong Kong), Esri Korea, '
                                    'Esri (Thailand), NGCC, © OpenStreetMap '
                                    'contributors, and the GIS User Community',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Aviso do modo de adição por toque
                  if (_modoAdicionar)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: _avisoFlutuante(
                        icone: Icons.touch_app,
                        cor: Colors.orange.shade700,
                        texto: 'Toque no mapa onde fica o novo local',
                        acao: 'Cancelar',
                        onAcao: _alternarModoAdicionar,
                      ),
                    ),

                  if (_erroMapa && !_modoAdicionar)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: _avisoFlutuante(
                        icone: Icons.wifi_off_outlined,
                        cor: cs.primary,
                        texto: 'O mapa não carregou. Verifique a conexão.',
                        acao: 'Tentar',
                        onAcao: _tentarCarregarMapa,
                      ),
                    ),

                  // Botões flutuantes à direita, como no wireframe
                  Positioned(
                    right: 16,
                    bottom: 56,
                    child: Column(
                      children: [
                        _botaoRedondo(
                          icone: Icons.add_location_alt_outlined,
                          dica: _modoAdicionar
                              ? 'Cancelar adição'
                              : 'Adicionar local tocando no mapa',
                          ativo: _modoAdicionar,
                          corAtivo: Colors.orange.shade700,
                          onTap: _alternarModoAdicionar,
                        ),
                        const SizedBox(height: 12),
                        _botaoRedondo(
                          icone: Icons.my_location,
                          dica: 'Centralizar',
                          onTap: _recentralizar,
                        ),
                        const SizedBox(height: 12),
                        _botaoRedondo(
                          icone: Icons.layers_outlined,
                          dica: _satelite ? 'Mapa de ruas' : 'Satélite',
                          ativo: _satelite,
                          corAtivo: cs.primary,
                          onTap: () => setState(() {
                            _satelite = !_satelite;
                            _erroMapa = false;
                          }),
                        ),
                      ],
                    ),
                  ),

                  // Atalho para a lista de resultados
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: const StadiumBorder(),
                        elevation: 3,
                      ),
                      onPressed: () =>
                          _abrirResultados(pesquisa: _pesquisaController.text),
                      icon: const Icon(Icons.format_list_bulleted, size: 20),
                      label: Text(
                        'Ver lista · $total ${total == 1 ? 'local' : 'locais'}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Topo do wireframe: "Cidade selecionada" + campo de busca.
  Widget _buildCabecalho() {
    final cs = Theme.of(context).colorScheme;
    final podeVoltar = Navigator.of(context).canPop();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              if (podeVoltar)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.pop(context),
                ),
              PopupMenuButton<String>(
                tooltip: 'Selecionar cidade',
                initialValue: _cidadeSelecionada,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: _moverParaCidade,
                itemBuilder: (_) => _cidadeCentros.keys
                    .map(
                      (cidade) => PopupMenuItem(
                        value: cidade,
                        child: Row(
                          children: [
                            Icon(
                              cidade == _cidadeSelecionada
                                  ? Icons.check
                                  : Icons.location_city_outlined,
                              size: 20,
                              color: cidade == _cidadeSelecionada
                                  ? cs.primary
                                  : cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(cidade),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 30,
                        color: cs.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cidade selecionada',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _cidadeSelecionada,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: cs.onSurface,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pesquisaController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar locais, endereços ou categorias...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _pesquisaController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _pesquisaController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (texto) {
              if (texto.trim().isNotEmpty) {
                _abrirResultados(pesquisa: texto.trim());
              }
            },
          ),
        ],
      ),
    );
  }

  Marker _marcador(Local local, LatLng ponto) {
    final cor = corCategoria(local.categoria);

    return Marker(
      point: ponto,
      width: 116,
      height: 76,
      child: GestureDetector(
        onTap: () => Navigator.push<void>(
          context,
          criarRota(DetalhesScreen(local: local)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 110),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                local.nome.length > 14
                    ? '${local.nome.substring(0, 14)}…'
                    : local.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 42,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.location_on, color: cor, size: 42),
                  Positioned(
                    top: 5,
                    child: Icon(
                      iconeCategoria(local.categoria),
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoRedondo({
    required IconData icone,
    required String dica,
    required VoidCallback onTap,
    bool ativo = false,
    Color? corAtivo,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: dica,
      child: Material(
        color: ativo ? corAtivo : Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black38,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icone,
              color: ativo ? Colors.white : cs.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _avisoFlutuante({
    required IconData icone,
    required Color cor,
    required String texto,
    required String acao,
    required VoidCallback onAcao,
  }) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        child: Row(
          children: [
            Icon(icone, color: cor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(onPressed: onAcao, child: Text(acao)),
          ],
        ),
      ),
    );
  }
}
