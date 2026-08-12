import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AlteradorHumorApp(),
  ));
}

class AlteradorHumorApp extends StatefulWidget {
  @override
  _AlteradorHumorAppState createState() => _AlteradorHumorAppState();
}

class _AlteradorHumorAppState extends State<AlteradorHumorApp> {
  String humor = "Feliz";
  String emoji = "😀";
  Color corDeFundo = Colors.green;

  void mudarHumor() {
    setState(() {
      if (humor == "Feliz") {
        humor = "Neutro";
        emoji = "😐";
        corDeFundo = Colors.blueGrey;
      } else if (humor == "Neutro") {
        humor = "Bravo";
        emoji = "😡";
        corDeFundo = Colors.red;
      } else {
        humor = "Feliz";
        emoji = "😀";
        corDeFundo = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meu Humor"),
        backgroundColor: corDeFundo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 100),
            ),
            SizedBox(height: 20),
            Text(
              "Eu estou $humor",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: mudarHumor,
              style: ElevatedButton.styleFrom(
                backgroundColor: corDeFundo,
              ),
              child: Text(
                "Mudar Humor",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}