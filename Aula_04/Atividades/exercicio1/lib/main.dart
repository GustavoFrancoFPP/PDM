import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<String> tarefas = [];
  final TextEditingController controller = TextEditingController();

  void adicionarTarefa() {
    final texto = controller.text.trim();
    if (texto.isEmpty) return; // não adiciona vazio

    setState(() {
      tarefas.add(texto);
      controller.clear();
    });
  }

  void removerTarefa(int index) {
    setState(() {
      tarefas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página de Tarefas (${tarefas.length})"),
      ),
      body: Column(
        children: [
          TextField(
            controller: controller,
            onSubmitted: (_) => adicionarTarefa(),
          ),
          ElevatedButton(
            onPressed: adicionarTarefa,
            child: const Text("Adicionar"),
          ),
          Expanded(
            child: tarefas.isEmpty
                ? const Center(child: Text('Nenhuma tarefa'))
                : ListView.builder(
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(tarefas[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removerTarefa(index),
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

// Respostas às perguntas.
//
// PARTE 1:
// - Dentro de runApp precisamos passar o widget raiz da aplicação: uma
//   instância de MyApp.
//
// PARTE 2:
// - TodoPage estende StatefulWidget e seu createState retorna _TodoPageState.
// - O estado é construído na classe _TodoPageState com o scaffold básico.
//
// PARTE 3:
// - A lista de tarefas (tarefas) está dentro de _TodoPageState porque faz
//   parte do estado da tela; cada instância de página precisa ter sua própria
//   cópia, e não um valor global.
// - O controller é um TextEditingController, usado para acessar e limpar o
//   texto digitado no TextField.
//
// PARTE 5:
// - Sem o setState a interface não se atualiza: a lista não muda visualmente.
// - Para limpar o campo usamos controller.clear().
//
// PARTE 6:
// - index é a posição atual do item sendo construído.
// - .length informa ao ListView quantos itens existem, para saber quando
//   parar de construir.