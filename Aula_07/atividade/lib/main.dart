import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TelaInicial(),
  ));
}

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person, color: Colors.red),
            title: Text('Gustavo'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SegundaTela(nome: 'Gustavo', telefone: '1111-1111'),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star, color: Colors.green),
            title: Text('Ana'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SegundaTela(nome: 'Ana', telefone: '2222-2222'),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.work, color: Colors.purple),
            title: Text('Carlos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SegundaTela(nome: 'Carlos', telefone: '3333-3333'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SegundaTela extends StatelessWidget {
  final String nome;
  final String telefone;

  SegundaTela({required this.nome, required this.telefone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),
        backgroundColor: Colors.yellow,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nome: $nome'),
            Text('Telefone: $telefone'),
            ElevatedButton(
              onPressed: () {
                final snackBar = SnackBar(content: Text('Ligando para $nome... ☎️'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text('Ligar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}