import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import '../widgets/transicao_tela.dart';
import 'detalhes_screen.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LocalService();

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: StreamBuilder<List<Local>>(
        stream: service.listarLocais(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final favoritos =
              (snapshot.data ?? []).where((l) => l.favorito).toList();

          if (favoritos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 38,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum favorito ainda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF17324D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Toque no coração na tela de detalhes\npara salvar um local aqui.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: favoritos.length,
            itemBuilder: (context, i) {
              final local = favoritos[i];
              return LocalCard(
                local: local,
                onTap: () => Navigator.push<void>(
                  context,
                  criarRota(DetalhesScreen(local: local)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
