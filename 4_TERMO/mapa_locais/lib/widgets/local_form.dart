import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../dialogs/selecionar_local_dialog.dart';
import '../models/local.dart';
import 'horario_picker.dart';

const List<String> _cidades = ['São Paulo', 'Campinas', 'Jundiaí'];
const List<String> _categorias = [
  'Academia',
  'Restaurante',
  'Hospital',
  'Museu',
  'Parque',
  'Escola',
  'Hotel',
  'Farmácia',
  'Mercado',
  'Outro',
];

class LocalForm extends StatefulWidget {
  final Local? local;

  // Posição já escolhida tocando no mapa principal (opcional).
  final double? latitudePinada;
  final double? longitudePinada;

  // Cidade pré-selecionada (a que está ativa no mapa).
  final String? cidadeSugerida;

  final void Function(Local local) onSalvar;

  const LocalForm({
    super.key,
    this.local,
    this.latitudePinada,
    this.longitudePinada,
    this.cidadeSugerida,
    required this.onSalvar,
  });

  @override
  State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _avaliacaoCtrl;
  late final TextEditingController _distanciaCtrl;
  late final TextEditingController _descricaoCtrl;

  late String _cidadeSelecionada;
  late String _categoriaSelecionada;
  late String _horario;

  // Posição marcada no mapa (null = ainda não marcou)
  LatLng? _posicao;
  bool _mostrarErroPosicao = false;

  @override
  void initState() {
    super.initState();
    final local = widget.local;

    _nomeCtrl = TextEditingController(text: local?.nome ?? '');
    _avaliacaoCtrl = TextEditingController(
      text: local != null ? local.avaliacao.toStringAsFixed(1) : '',
    );
    _distanciaCtrl = TextEditingController(
      text: local != null ? local.distancia.toStringAsFixed(1) : '',
    );
    _descricaoCtrl = TextEditingController(text: local?.descricao ?? '');
    _horario = local?.horario ?? '';

    if (local != null && _cidades.contains(local.cidade)) {
      _cidadeSelecionada = local.cidade;
    } else if (_cidades.contains(widget.cidadeSugerida)) {
      _cidadeSelecionada = widget.cidadeSugerida!;
    } else {
      _cidadeSelecionada = _cidades.first;
    }

    _categoriaSelecionada =
        local != null && _categorias.contains(local.categoria)
            ? local.categoria
            : _categorias.first;

    if (widget.latitudePinada != null && widget.longitudePinada != null) {
      _posicao = LatLng(widget.latitudePinada!, widget.longitudePinada!);
    } else if (local != null) {
      _posicao = LatLng(local.latitude, local.longitude);
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _avaliacaoCtrl.dispose();
    _distanciaCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  double? _lerNumero(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  // Abre o mapa em tela cheia para o usuário tocar no local.
  Future<void> _marcarNoMapa() async {
    final coordCidade = cidadeLatLng[_cidadeSelecionada]!;
    final escolhido = await selecionarLocalNoMapa(
      context,
      centro: LatLng(coordCidade.$1, coordCidade.$2),
      posicaoAtual: _posicao,
    );
    if (escolhido == null || !mounted) return;

    setState(() {
      _posicao = escolhido;
      _mostrarErroPosicao = false;
      _cidadeSelecionada = _cidadeMaisProxima(escolhido);
    });
  }

  // Define a cidade automaticamente pela que estiver mais perto do ponto.
  String _cidadeMaisProxima(LatLng ponto) {
    const distancia = Distance();
    var melhor = _cidadeSelecionada;
    var menor = double.infinity;
    cidadeLatLng.forEach((cidade, coord) {
      final d = distancia(ponto, LatLng(coord.$1, coord.$2));
      if (d < menor) {
        menor = d;
        melhor = cidade;
      }
    });
    return melhor;
  }

  void _salvar() {
    final formOk = _formKey.currentState!.validate();
    if (_posicao == null) {
      setState(() => _mostrarErroPosicao = true);
    }
    if (!formOk || _posicao == null) return;

    final local = Local(
      id: widget.local?.id ?? '',
      nome: _nomeCtrl.text.trim(),
      categoria: _categoriaSelecionada,
      cidade: _cidadeSelecionada,
      avaliacao: _lerNumero(_avaliacaoCtrl.text) ?? 0,
      distancia: _lerNumero(_distanciaCtrl.text) ?? 0,
      horario: _horario,
      descricao: _descricaoCtrl.text.trim(),
      favorito: widget.local?.favorito ?? false,
      latitude: _posicao!.latitude,
      longitude: _posicao!.longitude,
    );
    widget.onSalvar(local);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      child: Icon(
                        widget.local == null
                            ? Icons.add_location_alt_outlined
                            : Icons.edit_location_alt_outlined,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.local == null ? 'Novo local' : 'Editar local',
                          style: tema.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Preencha as informações abaixo'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nomeCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome do local *',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (valor) {
                    final nome = valor?.trim() ?? '';
                    if (nome.isEmpty) return 'Informe o nome do local.';
                    if (nome.length < 3) return 'Digite pelo menos 3 caracteres.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _categoriaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categorias
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (valor) {
                    if (valor != null) setState(() => _categoriaSelecionada = valor);
                  },
                ),
                const SizedBox(height: 12),

                // A key muda quando a cidade é ajustada pelo mapa,
                // para o dropdown mostrar o novo valor.
                DropdownButtonFormField<String>(
                  key: ValueKey(_cidadeSelecionada),
                  initialValue: _cidadeSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Cidade',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  items: _cidades
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (valor) {
                    if (valor != null) setState(() => _cidadeSelecionada = valor);
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  'Horário de funcionamento',
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                HorarioPicker(
                  valorInicial: _horario,
                  onChanged: (valor) => _horario = valor,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _avaliacaoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Avaliação (0–5) *',
                          prefixIcon: Icon(Icons.star_outline),
                        ),
                        validator: (valor) {
                          final n = _lerNumero(valor ?? '');
                          if (n == null || !n.isFinite) return 'Informe um número.';
                          if (n < 0 || n > 5) return 'Use 0 a 5.';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _distanciaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Distância (km)',
                          prefixIcon: Icon(Icons.directions_walk_outlined),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) return null;
                          final n = _lerNumero(valor);
                          if (n == null || !n.isFinite || n < 0) {
                            return 'Use um número ≥ 0.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descricaoCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 18),

                // Localização: marcada tocando no mapa
                Text(
                  'Localização *',
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _posicao != null
                        ? cs.primaryContainer
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: _mostrarErroPosicao
                        ? Border.all(color: cs.error)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _posicao != null
                            ? Icons.check_circle
                            : Icons.location_off_outlined,
                        color: _posicao != null
                            ? cs.primary
                            : (_mostrarErroPosicao ? cs.error : cs.outline),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _posicao != null
                              ? 'Local marcado no mapa ($_cidadeSelecionada)'
                              : 'Nenhum local marcado ainda',
                          style: TextStyle(
                            color: _mostrarErroPosicao ? cs.error : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_mostrarErroPosicao)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'Marque o local no mapa antes de salvar.',
                      style: TextStyle(color: cs.error, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _marcarNoMapa,
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: Text(
                      _posicao == null ? 'Marcar local no mapa' : 'Alterar local no mapa',
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _salvar,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      widget.local == null ? 'Salvar local' : 'Atualizar local',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
