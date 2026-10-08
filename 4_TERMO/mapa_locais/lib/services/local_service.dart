import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/local.dart';

class LocalService {
  final CollectionReference locais =
      FirebaseFirestore.instance.collection('locais');

  Stream<List<Local>> listarLocais() {
    return locais.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Local.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  List<Local> filtrarLocais(
    List<Local> locais,
    String texto,
    String cidade,
    String categoria,
  ) {
    return locais.where((local) {
      final correspondeCidade =
          cidade == 'Todas' || local.cidade == cidade;
      final correspondeCategoria =
          categoria == 'Todos' || local.categoria == categoria;
      final termo = texto.toLowerCase();
      final correspondeTexto =
          local.nome.toLowerCase().contains(termo) ||
              local.categoria.toLowerCase().contains(termo);

      return correspondeCidade &&
          correspondeCategoria &&
          correspondeTexto;
    }).toList();
  }

  Future<void> adicionar(Local local) async {
    await locais.add(local.toMap());
  }

  Future<void> atualizar(Local local) async {
    await locais.doc(local.id).update(local.toMap());
  }

  Future<void> excluir(String id) async {
    await locais.doc(id).delete();
  }

  Future<void> alterarFavorito(
    String id,
    bool favorito,
  ) async {
    await locais.doc(id).update({
      'favorito': favorito,
    });
  }
}
