import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InterruptorApp(),
  ));
}

class InterruptorApp extends StatefulWidget {
  @override
  _InterruptorAppState createState() => _InterruptorAppState();
}

class _InterruptorAppState extends State<InterruptorApp> {
  bool estaAceso = false;

  void alternarLuz() {
    setState(() {
      estaAceso = !estaAceso;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: estaAceso ? const Color.fromARGB(255, 255, 246, 125) : Colors.purple,
      appBar: AppBar(
        title: Text(
          "Interruptor",
          style: TextStyle(color: estaAceso ? Colors.black : Colors.white),
        ),
        backgroundColor: estaAceso ? Colors.orange : Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              estaAceso ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 100,
              color: estaAceso ? Colors.orange : Colors.white,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: alternarLuz,
              style: ElevatedButton.styleFrom(
                backgroundColor: estaAceso ? Colors.yellow : Colors.white,
              ),
              child: Text(
                "Interruptor",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}