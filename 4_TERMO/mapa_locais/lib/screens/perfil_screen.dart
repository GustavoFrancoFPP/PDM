import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cabeçalho
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.primary, const Color(0xFF0D47A1)],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: const Icon(
                    Icons.location_city,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mapa de Locais',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Versão 1.0.0',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Aplicativo para gerenciar e visualizar locais de interesse em cidades, com integração ao Firebase Firestore.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tecnologias
          _secao(context, 'Tecnologias utilizadas', [
            _item(Icons.flutter_dash, 'Flutter 3.x + Dart'),
            _item(Icons.cloud, 'Firebase Core + Cloud Firestore'),
            _item(Icons.map, 'flutter_map + latlong2 (OpenStreetMap / ESRI)'),
            _item(Icons.satellite_alt, 'Tiles satélite ESRI World Imagery (sem API key)'),
          ]),

          const SizedBox(height: 16),

          // Funcionalidades
          _secao(context, 'Funcionalidades', [
            _item(Icons.check_circle, 'Mapa interativo com satélite e modo rua'),
            _item(Icons.check_circle, 'Busca e filtros por cidade e categoria'),
            _item(Icons.check_circle, 'CRUD completo (criar, editar, excluir)'),
            _item(Icons.check_circle, 'Favoritar locais'),
            _item(Icons.check_circle, 'Detalhes e navegação entre telas'),
            _item(Icons.check_circle, 'Dados em tempo real via Firestore streams'),
          ]),

          const SizedBox(height: 16),

          // Tabela de testes
          Text('Tabela de Testes',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(44),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
                3: FixedColumnWidth(52),
              },
              children: [
                _headerRow(cs),
                ..._casos.map((c) => _testeRow(c, cs)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Desenvolvido por Gustavo Franco — SENAI 2026',
            style: TextStyle(color: cs.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _secao(BuildContext context, String titulo, List<Widget> itens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: itens),
          ),
        ),
      ],
    );
  }

  Widget _item(IconData icon, String texto) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(texto),
    );
  }

  TableRow _headerRow(ColorScheme cs) {
    return TableRow(
      decoration: BoxDecoration(color: cs.primaryContainer),
      children: [
        _cell('ID', bold: true),
        _cell('Cenário', bold: true),
        _cell('Resultado esperado', bold: true),
        _cell('Status', bold: true),
      ],
    );
  }

  TableRow _testeRow(Map<String, String> c, ColorScheme cs) {
    final ok = c['status'] == 'OK';
    return TableRow(
      children: [
        _cell(c['id']!),
        _cell(c['cenario']!),
        _cell(c['esperado']!),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ok ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              c['status']!,
              style: TextStyle(
                  color: ok ? Colors.green.shade800 : Colors.red.shade800,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(String texto, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        texto,
        style: TextStyle(
            fontSize: 11, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  static const _casos = [
    {
      'id': 'T01',
      'cenario': 'Abrir o app',
      'esperado': 'Tela do mapa carrega',
      'status': 'OK',
    },
    {
      'id': 'T02',
      'cenario': 'Selecionar cidade',
      'esperado': 'Mapa move para cidade',
      'status': 'OK',
    },
    {
      'id': 'T03',
      'cenario': 'Buscar local pelo nome',
      'esperado': 'Marcadores filtrados',
      'status': 'OK',
    },
    {
      'id': 'T04',
      'cenario': 'Filtrar por categoria',
      'esperado': 'Lista filtrada na tela',
      'status': 'OK',
    },
    {
      'id': 'T05',
      'cenario': 'Cadastrar novo local',
      'esperado': 'Local salvo no Firestore',
      'status': 'OK',
    },
    {
      'id': 'T06',
      'cenario': 'Editar local existente',
      'esperado': 'Dados atualizados',
      'status': 'OK',
    },
    {
      'id': 'T07',
      'cenario': 'Excluir local',
      'esperado': 'Local removido do Firestore',
      'status': 'OK',
    },
    {
      'id': 'T08',
      'cenario': 'Ver detalhes de um local',
      'esperado': 'Tela de detalhes abre',
      'status': 'OK',
    },
    {
      'id': 'T09',
      'cenario': 'Favoritar um local',
      'esperado': 'Aparece na aba Favoritos',
      'status': 'OK',
    },
    {
      'id': 'T10',
      'cenario': '"Ver no mapa" na tela de detalhes',
      'esperado': 'Mapa centraliza no local',
      'status': 'OK',
    },
    {
      'id': 'T11',
      'cenario': 'Alternar satélite/rua',
      'esperado': 'Tiles trocam corretamente',
      'status': 'OK',
    },
  ];
}
