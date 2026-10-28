import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/categoria_visual.dart';
import '../widgets/horario_picker.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import '../widgets/transicao_tela.dart';
import 'mapa_screen.dart';

class DetalhesScreen extends StatefulWidget {
  final Local local;

  const DetalhesScreen({super.key, required this.local});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  late Local local;

  @override
  void initState() {
    super.initState();
    local = widget.local;
  }

  Future<void> _toggleFavorito() async {
    try {
      final novoValor = !local.favorito;
      await LocalService().alterarFavorito(local.id, novoValor);
      if (!mounted) return;
      setState(() => local = local.copyWith(favorito: novoValor));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            novoValor ? 'Adicionado aos favoritos!' : 'Removido dos favoritos.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar favorito: $e')),
      );
    }
  }

  // "Compartilhar": copia as informações do local para a área de transferência.
  Future<void> _compartilhar() async {
    final texto = '${local.nome} (${local.categoria}) - ${local.cidade}\n'
        'Avaliação: ${numeroBr(local.avaliacao)} · ${numeroBr(local.distancia)} km\n'
        '${local.descricao}';
    await Clipboard.setData(ClipboardData(text: texto));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informações copiadas para compartilhar.')),
    );
  }

  Future<void> _abrirEdicao() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return LocalForm(
          local: local,
          onSalvar: (localEditado) async {
            final nav = Navigator.of(sheetContext);
            try {
              final atualizado = localEditado.copyWith(id: local.id);
              await LocalService().atualizar(atualizado);
              if (nav.mounted) nav.pop();
              if (!mounted) return;
              setState(() => local = atualizado);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Local atualizado com sucesso!')),
              );
            } catch (e) {
              if (nav.mounted) nav.pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao atualizar: $e')),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _excluirLocal() async {
    final nav = Navigator.of(context);
    final mensagens = ScaffoldMessenger.of(context);
    final confirmou = await showConfirmDeleteDialog(context, nome: local.nome);
    if (confirmou != true) return;

    try {
      await LocalService().excluir(local.id);
      mensagens.showSnackBar(
        const SnackBar(content: Text('Local excluído com sucesso!')),
      );
      if (nav.mounted) nav.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  void _verNoMapa() {
    Navigator.push<void>(
      context,
      criarRota(
        MapaScreen(
          focusLatitude: local.latitude,
          focusLongitude: local.longitude,
          focusNome: local.nome,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cor = corCategoria(local.categoria);
    final dias = horarioPorDia(local.horario);
    final situacao = situacaoAgora(local.horario);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: local.favorito
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onPressed: _toggleFavorito,
            icon: Icon(
              local.favorito ? Icons.favorite : Icons.favorite_border,
              color: local.favorito ? Colors.red : null,
            ),
          ),
          IconButton(
            tooltip: 'Compartilhar',
            onPressed: _compartilhar,
            icon: const Icon(Icons.share_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          // Área da imagem, como no wireframe
          Container(
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cor.withValues(alpha: 0.75), cor],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -24,
                  bottom: -34,
                  child: Icon(
                    iconeCategoria(local.categoria),
                    size: 180,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                Center(
                  child: Icon(
                    iconeCategoria(local.categoria),
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nome, categoria e avaliação
          Text(
            local.nome,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            local.categoria,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 4),
              Text(
                numeroBr(local.avaliacao),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '  de 5',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Distância e situação (aberto/fechado)
          Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              _info(
                Icons.location_on_outlined,
                '${numeroBr(local.distancia)} km · ${local.cidade}',
              ),
              if (situacao != null)
                _info(
                  Icons.schedule,
                  situacao.aberto
                      ? 'Aberto · ${situacao.horarioHoje}'
                      : (situacao.horarioHoje == 'Fechado hoje'
                          ? 'Fechado hoje'
                          : 'Fechado agora · ${situacao.horarioHoje}'),
                  destaque: situacao.aberto
                      ? Colors.green.shade700
                      : cs.error,
                )
              else if (local.horario.isNotEmpty)
                _info(Icons.schedule, local.horario),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),

          // Ações rápidas em círculos
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _acao(Icons.near_me_outlined, 'Como chegar', _verNoMapa),
                _acao(Icons.edit_outlined, 'Editar', _abrirEdicao),
                _acao(
                  Icons.delete_outline,
                  'Excluir',
                  _excluirLocal,
                  cor: cs.error,
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 12),

          _titulo('Sobre'),
          Text(
            local.descricao.trim().isNotEmpty
                ? local.descricao.trim()
                : 'Nenhuma descrição foi adicionada.',
            style: TextStyle(height: 1.5, color: cs.onSurface),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          _titulo('Horário de funcionamento'),
          if (dias.isEmpty)
            Text(
              local.horario.isNotEmpty ? local.horario : 'Horário não informado.',
            )
          else
            for (final (dia, valor) in dias) _linhaHorario(dia, valor),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF263238),
            ),
            onPressed: _verNoMapa,
            icon: const Icon(Icons.location_on),
            label: const Text('Ver no mapa'),
          ),
        ),
      ),
    );
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _info(IconData icone, String texto, {Color? destaque}) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 18, color: destaque ?? cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            color: destaque ?? cs.onSurface,
            fontWeight: destaque != null ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _acao(IconData icone, String texto, VoidCallback onTap, {Color? cor}) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(icone, color: cor ?? cs.onSurface, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cor ?? cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaHorario(String dia, String valor) {
    final cs = Theme.of(context).colorScheme;
    final fechado = valor == 'Fechado';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(dia, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          Text(
            valor,
            style: TextStyle(
              color: fechado ? cs.error : cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
