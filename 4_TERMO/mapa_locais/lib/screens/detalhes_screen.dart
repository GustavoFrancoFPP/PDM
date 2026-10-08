import 'package:flutter/material.dart';

import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_form.dart';

class DetalhesScreen extends StatefulWidget {
  final Local local;

  const DetalhesScreen({
    super.key,
    required this.local,
  });

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
    await LocalService().alterarFavorito(local.id, !local.favorito);
    setState(() {
      local = local.copyWith(favorito: !local.favorito);
    });
  }

  Future<void> _abrirEdicao() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return LocalForm(
          local: local,
          onSalvar: (localEditado) async {
            final navigator = Navigator.of(sheetContext);
            await LocalService().atualizar(localEditado);
            if (navigator.mounted) {
              navigator.pop();
            }
            if (!mounted) return;
            setState(() {
              local = localEditado;
            });
          },
        );
      },
    );
  }

  Future<void> _excluirLocal() async {
    final navigator = Navigator.of(context);
    final confirmou = await showConfirmDeleteDialog(context, nome: local.nome);

    if (confirmou == true) {
      await LocalService().excluir(local.id);
      if (navigator.mounted) {
        navigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(local.nome),
        actions: [
          IconButton(
            onPressed: _toggleFavorito,
            icon: Icon(
              local.favorito ? Icons.favorite : Icons.favorite_border,
              color: local.favorito ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              local.categoria,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined),
                const SizedBox(width: 8),
                Text(local.cidade),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_outlined),
                const SizedBox(width: 8),
                Text(local.horario),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star_outline),
                const SizedBox(width: 8),
                Text(local.avaliacao.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_walk_outlined),
                const SizedBox(width: 8),
                Text('${local.distancia.toStringAsFixed(1)} km'),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Descrição',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(local.descricao),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _abrirEdicao,
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _excluirLocal,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
