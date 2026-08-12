import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class DatabaseHelper {
  static Database? _db;
  
  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = p.join(await getDatabasesPath(), 'cadastro.db');
    return openDatabase(path, onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dados(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, descricao TEXT, data TEXT)'
      );
    }, version: 1);
  }

  Future<int> insert(String titulo, String descricao) async {
    final db = await database;
    final now = DateTime.now().toString().split('.')[0];
    return db.insert('dados', {'titulo': titulo, 'descricao': descricao, 'data': now});
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return db.query('dados', orderBy: 'titulo ASC');
  }

  Future<int> update(int id, String titulo, String descricao) async {
    final db = await database;
    return db.update('dados', {'titulo': titulo, 'descricao': descricao}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('dados', where: 'id = ?', whereArgs: [id]);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    final data = await db.getAll();
    setState(() => items = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro Inteligente')),
      body: items.isEmpty
          ? const Center(child: Text('Nenhum item cadastrado'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return ListTile(
                  title: Text(item['titulo']),
                  subtitle: Text('${item['descricao']}\n${item['data'] ?? 'Sem data'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditPage(item: item)),
                        ).then((_) => _load()),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await db.delete(item['id']);
                          _load();
                        },
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPage()),
        ).then((_) => _load()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  const AddPage({super.key});
  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final db = DatabaseHelper();
  final titulo = TextEditingController();
  final descricao = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Item')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titulo,
              decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descricao,
              decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (titulo.text.isNotEmpty && descricao.text.isNotEmpty) {
                  await db.insert(titulo.text, descricao.text);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titulo.dispose();
    descricao.dispose();
    super.dispose();
  }
}

class EditPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const EditPage({required this.item, super.key});
  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final db = DatabaseHelper();
  late TextEditingController titulo;
  late TextEditingController descricao;

  @override
  void initState() {
    super.initState();
    titulo = TextEditingController(text: widget.item['titulo']);
    descricao = TextEditingController(text: widget.item['descricao']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Item')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titulo,
              decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descricao,
              decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await db.update(widget.item['id'], titulo.text, descricao.text);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titulo.dispose();
    descricao.dispose();
    super.dispose();
  }
}

