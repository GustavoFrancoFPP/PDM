import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CadastroAlunosApp(),
  ));
}

class CadastroAlunosApp extends StatefulWidget {
  const CadastroAlunosApp({super.key});

  @override
  State<CadastroAlunosApp> createState() => _CadastroAlunosAppState();
}

class _CadastroAlunosAppState extends State<CadastroAlunosApp> {
  List<Map<String, String>> alunos = [];

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController cursoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void dispose() {
    nomeController.dispose();
    idadeController.dispose();
    cursoController.dispose();
    super.dispose();
  }

  void cadastrarAluno() {
    if (nomeController.text.isNotEmpty &&
        idadeController.text.isNotEmpty &&
        cursoController.text.isNotEmpty) {
      setState(() {
        alunos.add({
          'nome': nomeController.text,
          'idade': idadeController.text,
          'curso': cursoController.text,
        });
      });

      nomeController.clear();
      idadeController.clear();
      cursoController.clear();

      salvarDados();
    }
  }

  void limparLista() {
    setState(() {
      alunos.clear();
    });
    salvarDados();
  }

  void salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> alunosJson = alunos.map((aluno) => jsonEncode(aluno)).toList();
    await prefs.setStringList("alunos", alunosJson);
  }

  void carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> alunosJson = prefs.getStringList("alunos") ?? [];
    setState(() {
      alunos = alunosJson
          .map((item) => Map<String, String>.from(jsonDecode(item)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Alunos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: limparLista,
            tooltip: 'Limpar Lista',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Aluno',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: idadeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Idade do Aluno',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cursoController,
                  decoration: const InputDecoration(
                    labelText: 'Curso do Aluno',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: cadastrarAluno,
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar Aluno'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: alunos.length,
              itemBuilder: (context, index) {
                final aluno = alunos[index];
                return ListTile(
                  title: Text(
                    aluno['nome'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Idade: ${aluno['idade']} anos | Curso: ${aluno['curso']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        alunos.removeAt(index);
                      });
                      salvarDados();
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