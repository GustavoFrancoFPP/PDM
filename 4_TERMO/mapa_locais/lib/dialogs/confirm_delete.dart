import 'package:flutter/material.dart';

Future<bool?> showConfirmDeleteDialog(BuildContext context, {required String nome}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final erro = Theme.of(context).colorScheme.error;
      return AlertDialog(
        icon: CircleAvatar(
          radius: 26,
          backgroundColor: erro.withValues(alpha: 0.1),
          child: Icon(Icons.delete_outline, color: erro, size: 28),
        ),
        title: const Text('Excluir local?'),
        content: Text(
          '"$nome" será removido. Essa ação não poderá ser desfeita.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: erro),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
}
