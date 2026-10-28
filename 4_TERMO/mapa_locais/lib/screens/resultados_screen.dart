import 'package:flutter/material.dart';

import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import '../widgets/transicao_tela.dart';
import 'detalhes_screen.dart';

class ResultadosScreen extends StatefulWidget {
  final String cidade;
  final String pesquisa;
  final String categoria;

  const ResultadosScreen({
    super.key,
    this.cidade = 'Todas',
    this.pesquisa = '',
    this.categoria = 'Todos',
  });

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final LocalService _service = LocalService();
  late TextEditingController _pesquisaController;
  late String _cidadeSelecionada;
  late String _categoriaSelecionada;

  final List<String> _cidades = ['Todas', 'São Paulo', 'Campinas', 'Jundiaí'];
  final List<String> _categorias = [
    'Todos',
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

  // Rótulos dos chips no plural, como no wireframe.
  static const _rotulos = {
    'Todos': 'Todos',
    'Academia': 'Academias',
    'Restaurante': 'Restaurantes',
    'Hospital': 'Hospitais',
    'Museu': 'Museus',
    'Parque': 'Parques',
    'Escola': 'Escolas',
    'Hotel': 'Hotéis',
    'Farmácia': 'Farmácias',
    'Mercado': 'Mercados',
    'Outro': 'Outros',
  };

  Future<void> _escolherCidade() async {
    final escolhida = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Selecionar cidade',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            for (final cidade in _cidades)
              ListTile(
                leading: Icon(
                  cidade == _cidadeSelecionada
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: cidade == _cidadeSelecionada
                      ? Theme.of(ctx).colorScheme.primary
                      : null,
                ),
                title: Text(cidade == 'Todas' ? 'Todas as cidades' : cidade),
                onTap: () => Navigator.pop(ctx, cidade),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (escolhida != null) setState(() => _cidadeSelecionada = escolhida);
  }

  @override
  void initState() {
    super.initState();
    _pesquisaController = TextEditingController(text: widget.pesquisa);
    _cidadeSelecionada = widget.cidade;
    _categoriaSelecionada = widget.categoria;
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario({Local? local}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return LocalForm(
          local: local,
          cidadeSugerida:
              _cidadeSelecionada == 'Todas' ? null : _cidadeSelecionada,
          onSalvar: (localSalvo) async {
            final navigator = Navigator.of(sheetContext);
            try {
              if (local == null) {
                await _service.adicionar(localSalvo);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Local cadastrado com sucesso!')),
                  );
                }
              } else {
                await _service.atualizar(localSalvo.copyWith(id: local.id));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Local atualizado com sucesso!')),
                  );
                }
              }
              if (navigator.mounted) navigator.pop();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar: $e')),
                );
              }
            }
          },
        );
      },
    );
  }

  Future<void> _excluir(Local local) async {
    final confirmou = await showConfirmDeleteDialog(context, nome: local.nome);
    if (confirmou == true) {
      try {
        await _service.excluir(local.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local excluído com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo local'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _pesquisaController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por nome ou categoria',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _pesquisaController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _pesquisaController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                // Linha da cidade, igual ao wireframe: "📍 São Paulo  >"
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _escolherCidade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _cidadeSelecionada == 'Todas'
                                  ? 'Todas as cidades'
                                  : _cidadeSelecionada,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filtro de categoria em chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categorias.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final categoria = _categorias[i];
                final selecionada = categoria == _categoriaSelecionada;
                return ChoiceChip(
                  label: Text(_rotulos[categoria] ?? categoria),
                  showCheckmark: false,
                  selected: selecionada,
                  selectedColor: const Color(0xFF263238),
                  labelStyle: TextStyle(
                    color: selecionada ? Colors.white : const Color(0xFF17324D),
                    fontWeight: selecionada ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selecionada
                        ? const Color(0xFF263238)
                        : const Color(0xFFE2E8F0),
                  ),
                  onSelected: (_) =>
                      setState(() => _categoriaSelecionada = categoria),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Local>>(
              stream: _service.listarLocais(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _estadoVazio(
                    Icons.cloud_off_outlined,
                    'Erro ao carregar os locais',
                    '${snapshot.error}',
                  );
                }

                final locaisFiltrados = _service.filtrarLocais(
                  snapshot.data ?? [],
                  _pesquisaController.text,
                  _cidadeSelecionada,
                  _categoriaSelecionada,
                );

                if (locaisFiltrados.isEmpty) {
                  return _estadoVazio(
                    Icons.search_off,
                    'Nenhum local encontrado',
                    'Tente outra pesquisa ou mude os filtros.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: locaisFiltrados.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 2),
                        child: Text(
                          locaisFiltrados.length == 1
                              ? '1 resultado'
                              : '${locaisFiltrados.length} resultados',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    final local = locaisFiltrados[index - 1];
                    return LocalCard(
                      local: local,
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          criarRota(DetalhesScreen(local: local)),
                        );
                      },
                      onEdit: () => _abrirFormulario(local: local),
                      onDelete: () => _excluir(local),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoVazio(IconData icone, String titulo, String texto) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEF7),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 36, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF17324D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
