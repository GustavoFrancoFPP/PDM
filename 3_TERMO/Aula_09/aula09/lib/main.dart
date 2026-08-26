import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AppBanco());
  }
}

class AppBanco extends StatefulWidget {
  const AppBanco({super.key});

  @override
  AppBancoState createState() => AppBancoState();
}

class AppBancoState extends State<AppBanco> {
  TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> tarefas = [];

  Future<Database> criarBanco() async {
    final caminho = await getDatabasesPath();
    final path = join(caminho, "banco.db");

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tarefas(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> inserirTarefa(String nome) async {
    final db = await criarBanco();

    await db.insert('tarefas', {'nome': nome});
    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    final db = await criarBanco();
    final lista = await db.query("tarefas");

    setState(() {
      tarefas = lista;
    });
  }

  Future<void> deletarTarefa(int id) async {
    final db = await criarBanco();

    await db.delete("tarefas", where: "id = ?", whereArgs: [id]);
    carregarTarefas();
  }

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Banco de Dados")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Nova Tarefa",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                inserirTarefa(controller.text);
                controller.clear();
              }
            },
            child: Text("Adicionar"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tarefas[index]['nome']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deletarTarefa(tarefas[index]['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
