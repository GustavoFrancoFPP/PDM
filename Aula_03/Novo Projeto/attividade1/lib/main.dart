import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(home: PaginaNumerosAleatorios()));
}

class PaginaNumerosAleatorios extends StatefulWidget {
  @override
  _PaginaNumerosAleatoriosState createState() => _PaginaNumerosAleatoriosState(); 
}

class _PaginaNumerosAleatoriosState extends State<PaginaNumerosAleatorios> {
  int numero = 0;
  void gerarNumero() {
    setState(() {
      numero = Random().nextInt(10) + 1;
    });



    }
    @override 
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('App de numero aleatório')),
        body: Center(
          child: Text('Numero: $numero', style: TextStyle(fontSize: 30)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: gerarNumero,
          child: Icon(Icons.refresh), 
          ),
      );
    }
  }
 
