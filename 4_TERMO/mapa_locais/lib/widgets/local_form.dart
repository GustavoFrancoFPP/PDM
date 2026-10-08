import 'package:flutter/material.dart';

import '../models/local.dart';

class LocalForm extends StatefulWidget {
  final Local? local;
  final void Function(Local local) onSalvar;

  const LocalForm({
    super.key,
    this.local,
    required this.onSalvar,
  });

  @override
  State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  late final TextEditingController nomeController;
  late final TextEditingController categoriaController;
  late final TextEditingController cidadeController;
  late final TextEditingController avaliacaoController;
  late final TextEditingController distanciaController;
  late final TextEditingController horarioController;
  late final TextEditingController descricaoController;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.local?.nome ?? '');
    categoriaController =
        TextEditingController(text: widget.local?.categoria ?? '');
    cidadeController = TextEditingController(text: widget.local?.cidade ?? '');
    avaliacaoController =
        TextEditingController(text: widget.local?.avaliacao.toString() ?? '');
    distanciaController =
        TextEditingController(text: widget.local?.distancia.toString() ?? '');
    horarioController = TextEditingController(text: widget.local?.horario ?? '');
    descricaoController =
        TextEditingController(text: widget.local?.descricao ?? '');
  }

  @override
  void dispose() {
    nomeController.dispose();
    categoriaController.dispose();
    cidadeController.dispose();
    avaliacaoController.dispose();
    distanciaController.dispose();
    horarioController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    final local = Local(
      id: widget.local?.id ?? '',
      nome: nomeController.text.trim(),
      categoria: categoriaController.text.trim().isEmpty
          ? 'Geral'
          : categoriaController.text.trim(),
      cidade: cidadeController.text.trim().isEmpty
          ? 'Geral'
          : cidadeController.text.trim(),
      avaliacao: double.tryParse(avaliacaoController.text) ?? 0,
      distancia: double.tryParse(distanciaController.text) ?? 0,
      horario: horarioController.text.trim(),
      descricao: descricaoController.text.trim(),
      favorito: widget.local?.favorito ?? false,
    );

    widget.onSalvar(local);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.local == null ? 'Novo local' : 'Editar local',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoriaController,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cidadeController,
              decoration: const InputDecoration(labelText: 'Cidade'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: horarioController,
              decoration: const InputDecoration(labelText: 'Horário'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: avaliacaoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Avaliação'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: distanciaController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Distância'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descricaoController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _salvar,
                child: Text(widget.local == null ? 'Salvar local' : 'Atualizar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
