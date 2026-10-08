import 'package:flutter/material.dart';

Future<bool?> showConfirmDeleteDialog(BuildContext context, {required String nome}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Excluir local'),
        content: Text('Deseja realmente excluir "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
}
