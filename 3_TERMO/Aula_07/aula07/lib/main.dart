import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: TelaInicial()),
  );
}

// Tela 1
class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tela Inicial'), backgroundColor: Colors.blue),
      body: Center(
        child: ElevatedButton(
          child: Text('Ir para Segunda Tela'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SegundaTela()),
            );
          },
        ),
      ),
    );
  }
}

//Tela 2

class SegundaTela extends StatelessWidget {
  const SegundaTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Segunda Tela'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Voltar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
