import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ListaComprasApp(),
  ));
}

class ListaComprasApp extends StatefulWidget {
  @override
  _ListaComprasAppState createState() => _ListaComprasAppState();
}

class _ListaComprasAppState extends State<ListaComprasApp> {
  List<String> itens = [];
  List<bool> comprado = [];
  late TextEditingController controller;

  void adicionarItem() {
    if (controller.text.isNotEmpty) {
      setState(() {
        itens.add(controller.text);
        comprado.add(false);
      });
      controller.clear();
      salvarDados();
    }
  }

  void alternarComprado(int index) {
    setState(() {
      comprado[index] = !comprado[index];
    });
    salvarDados();
  }

  void removerItem(int index) {
    setState(() {
      itens.removeAt(index);
      comprado.removeAt(index);
    });
    salvarDados();
  }

  void limparLista() {
    setState(() {
      itens.clear();
      comprado.clear();
    });
    salvarDados();
  }

  void salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("itens", itens);
    await prefs.setStringList(
      "comprado",
      comprado.map((e) => e.toString()).toList(),
    );
  }

  void carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itens = prefs.getStringList("itens") ?? [];
      List<String> listaBool = prefs.getStringList("comprado") ?? [];
      comprado = listaBool.map((e) => e == "true").toList();
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    carregarDados();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int itensComprados = comprado.where((e) => e).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Compras ($itensComprados/${itens.length})"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "Digite um item",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: adicionarItem,
                        child: Text("Adicionar"),
                      ),
                    ),
                    if (itens.isNotEmpty) ...[
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: limparLista,
                        child: Text("Limpar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: itens.isEmpty
                ? Center(child: Text("Nenhum item na lista"))
                : ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Checkbox(
                          value: comprado[index],
                          onChanged: (_) => alternarComprado(index),
                        ),
                        title: Text(
                          itens[index],
                          style: TextStyle(
                            decoration: comprado[index]
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: comprado[index]
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => removerItem(index),
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
