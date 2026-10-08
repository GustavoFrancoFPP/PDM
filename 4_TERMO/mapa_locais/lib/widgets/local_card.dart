import 'package:flutter/material.dart';

import '../models/local.dart';

class LocalCard extends StatelessWidget {
  final Local local;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const LocalCard({
    super.key,
    required this.local,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.location_on_outlined),
        ),
        title: Text(
          local.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${local.categoria} • ${local.cidade}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(local.avaliacao.toStringAsFixed(1)),
                const SizedBox(width: 12),
                const Icon(Icons.directions_walk, size: 16),
                const SizedBox(width: 4),
                Text('${local.distancia.toStringAsFixed(1)} km'),
              ],
            ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              )
            : local.favorito
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border),
        onTap: onTap,
      ),
    );
  }
}
