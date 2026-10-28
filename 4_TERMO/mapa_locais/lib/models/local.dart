// Coordenadas padrão por cidade
const Map<String, (double, double)> cidadeLatLng = {
  'São Paulo': (-23.5505, -46.6333),
  'Campinas': (-22.9035, -47.0623),
  'Jundiaí': (-23.1864, -46.8964),
};

class Local {
  final String id;
  final String nome;
  final String categoria;
  final String cidade;
  final double avaliacao;
  final double distancia;
  final String horario;
  final String descricao;
  final bool favorito;
  final double latitude;
  final double longitude;

  Local({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.cidade,
    required this.avaliacao,
    required this.distancia,
    required this.horario,
    required this.descricao,
    required this.favorito,
    required this.latitude,
    required this.longitude,
  });

  factory Local.fromMap(String id, Map<String, dynamic> data) {
    final cidade = data['cidade'] ?? '';
    final defaultCoord = cidadeLatLng[cidade] ?? (-23.5505, -46.6333);
    return Local(
      id: id,
      nome: data['nome'] ?? '',
      categoria: data['categoria'] ?? '',
      cidade: cidade,
      avaliacao: (data['avaliacao'] ?? 0).toDouble(),
      distancia: (data['distancia'] ?? 0).toDouble(),
      horario: data['horario'] ?? '',
      descricao: data['descricao'] ?? '',
      favorito: data['favorito'] ?? false,
      latitude: data['latitude'] != null
          ? (data['latitude'] as num).toDouble()
          : defaultCoord.$1,
      longitude: data['longitude'] != null
          ? (data['longitude'] as num).toDouble()
          : defaultCoord.$2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
      'cidade': cidade,
      'avaliacao': avaliacao,
      'distancia': distancia,
      'horario': horario,
      'descricao': descricao,
      'favorito': favorito,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Local copyWith({
    String? id,
    String? nome,
    String? categoria,
    String? cidade,
    double? avaliacao,
    double? distancia,
    String? horario,
    String? descricao,
    bool? favorito,
    double? latitude,
    double? longitude,
  }) {
    return Local(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      cidade: cidade ?? this.cidade,
      avaliacao: avaliacao ?? this.avaliacao,
      distancia: distancia ?? this.distancia,
      horario: horario ?? this.horario,
      descricao: descricao ?? this.descricao,
      favorito: favorito ?? this.favorito,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
