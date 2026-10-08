import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import 'detalhes_screen.dart';

class ResultadosScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final LocalService service = LocalService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
      ),
      body: StreamBuilder<List<Local>>(
        stream: service.listarLocais(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar os locais.'),
            );
          }

          final locais = service.filtrarLocais(
            snapshot.data ?? [],
            pesquisa,
            cidade,
            categoria,
          );

          if (locais.isEmpty) {
            return const Center(
              child: Text('Nenhum local encontrado.'),
            );
          }

          return ListView.builder(
            itemCount: locais.length,
            itemBuilder: (context, index) {
              final local = locais[index];
              return LocalCard(
                local: local,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalhesScreen(local: local),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
