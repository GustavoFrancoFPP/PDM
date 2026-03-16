import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SemaforoApp(),
  ));
}

class SemaforoApp extends StatefulWidget {
  const SemaforoApp({super.key});

  @override
  State<SemaforoApp> createState() => _SemaforoAppState();
}

class _SemaforoAppState extends State<SemaforoApp> {
  int estado = 0;

  void mudarSemaforo() {
    setState(() {
      estado = (estado + 1) % 3;
    });
  }

  Color _corVermelho() => estado == 2 ? Colors.red : Colors.grey[400]!;
  Color _corAmarelo() => estado == 1 ? Colors.yellow : Colors.grey[400]!;
  Color _corVerde() => estado == 0 ? Colors.green : Colors.grey[400]!;

  String _textoPedestre() {
    return estado == 2 ? 'PEDESTRE: ATRAVESSE' : 'PEDESTRE: AGUARDE';
  }

  IconData _iconePedestre() {
    return estado == 2 ? Icons.directions_walk : Icons.pan_tool;
  }

  Color _corPedestre() {
    return estado == 2 ? Colors.green : Colors.red;
  }

  Widget _semaforoWidget() {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _luzSemaforo(_corVermelho()),
          const SizedBox(height: 10),
          _luzSemaforo(_corAmarelo()),
          const SizedBox(height: 10),
          _luzSemaforo(_corVerde()),
        ],
      ),
    );
  }

  Widget _luzSemaforo(Color cor) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: cor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
    );
  }

  Widget _pedestreWidget() {
    return Column(
      children: [
        Icon(_iconePedestre(), size: 80, color: _corPedestre()),
        const SizedBox(height: 8),
        Text(
          _textoPedestre(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _botaoWidget() {
    return ElevatedButton(
      onPressed: mudarSemaforo,
      style: ElevatedButton.styleFrom(minimumSize: const Size(170, 48)),
      child: const Text('Mudar Semáforo'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Semáforo de Trânsito'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _semaforoWidget(),
            const SizedBox(height: 40),
            _pedestreWidget(),
            const SizedBox(height: 40),
            _botaoWidget(),
          ],
        ),
      ),
    );
  }
}
