import 'package:flutter/material.dart';

import '../models/local.dart';
import 'categoria_visual.dart';

// Número no formato brasileiro (vírgula decimal), como no wireframe.
String numeroBr(double valor) => valor.toStringAsFixed(1).replaceAll('.', ',');

class LocalCard extends StatelessWidget {
  final Local local;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LocalCard({
    super.key,
    required this.local,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final cor = corCategoria(local.categoria);
    final temAcoes = onEdit != null || onDelete != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // "Imagem" do local: bloco com a cor e o ícone da categoria
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cor.withValues(alpha: 0.18),
                      cor.withValues(alpha: 0.32),
                    ],
                  ),
                ),
                child: Icon(iconeCategoria(local.categoria), color: cor, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            local.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (local.favorito) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.favorite, color: Colors.red, size: 15),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      local.categoria,
                      style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    _linha(
                      Icons.location_on_outlined,
                      '${numeroBr(local.distancia)} km · ${local.cidade}',
                      cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 3),
                    _linha(
                      Icons.star_rounded,
                      numeroBr(local.avaliacao),
                      Colors.amber.shade700,
                    ),
                  ],
                ),
              ),
              if (temAcoes)
                PopupMenuButton<String>(
                  tooltip: 'Opções',
                  icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (opcao) {
                    if (opcao == 'editar') onEdit?.call();
                    if (opcao == 'excluir') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'editar',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'excluir',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline, color: cs.error),
                          title: Text(
                            'Excluir',
                            style: TextStyle(color: cs.error),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                )
              else
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linha(IconData icone, String texto, Color corIcone) {
    return Row(
      children: [
        Icon(icone, size: 15, color: corIcone),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
