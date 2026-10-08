import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_form.dart';
import 'resultados_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final TextEditingController pesquisaController = TextEditingController();
  String cidadeSelecionada = 'Todas';
  String categoriaSelecionada = 'Todos';
  final LocalService service = LocalService();

  Future<void> _abrirFormulario({Local? local}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return LocalForm(
          local: local,
          onSalvar: (localSalvo) async {
            if (local == null) {
              await service.adicionar(localSalvo);
            } else {
              await service.atualizar(localSalvo.copyWith(id: local.id));
            }

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cidades = ['Todas', 'São Paulo', 'Campinas', 'Jundiaí'];
    final categorias = ['Todos', 'Academia', 'Restaurante', 'Museu', 'Parque'];

    final markers = [
      const Offset(0.15, 0.30),
      const Offset(0.45, 0.28),
      const Offset(0.72, 0.20),
      const Offset(0.33, 0.72),
      const Offset(0.80, 0.70),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de locais'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: pesquisaController,
              decoration: const InputDecoration(
                labelText: 'Buscar local',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: cidadeSelecionada,
                    items: cidades
                        .map(
                          (cidade) => DropdownMenuItem(
                            value: cidade,
                            child: Text(cidade),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          cidadeSelecionada = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Cidade'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: categoriaSelecionada,
                    items: categorias
                        .map(
                          (categoria) => DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          categoriaSelecionada = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Categoria'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultadosScreen(
                        cidade: cidadeSelecionada,
                        pesquisa: pesquisaController.text,
                        categoria: categoriaSelecionada,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Ver resultados'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.shade100,
                        Colors.green.shade100,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MapBackgroundPainter(),
                        ),
                      ),
                      ...List.generate(markers.length, (index) {
                        final marker = markers[index];
                        final colors = [
                          Colors.red,
                          Colors.purple,
                          Colors.orange,
                          Colors.green,
                          Colors.blue,
                        ];

                        return Positioned(
                          left: marker.dx * MediaQuery.of(context).size.width,
                          top: marker.dy * 260,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colors[index],
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width * 0.10, size.height * 0.15)
      ..lineTo(size.width * 0.70, size.height * 0.20)
      ..lineTo(size.width * 0.82, size.height * 0.60)
      ..lineTo(size.width * 0.25, size.height * 0.80)
      ..lineTo(size.width * 0.10, size.height * 0.15);

    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.15),
      Offset(size.width * 0.70, size.height * 0.20),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.70, size.height * 0.20),
      Offset(size.width * 0.82, size.height * 0.60),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.82, size.height * 0.60),
      Offset(size.width * 0.25, size.height * 0.80),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.80),
      Offset(size.width * 0.10, size.height * 0.15),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
