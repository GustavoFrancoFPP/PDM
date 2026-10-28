import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Tela cheia onde o usuário toca no mapa para escolher a posição do local.
// Retorna o LatLng escolhido (ou null se cancelar).
Future<LatLng?> selecionarLocalNoMapa(
  BuildContext context, {
  required LatLng centro,
  LatLng? posicaoAtual,
}) {
  return Navigator.of(context).push<LatLng>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _SelecionarLocalTela(
        centro: posicaoAtual ?? centro,
        posicaoAtual: posicaoAtual,
      ),
    ),
  );
}

class _SelecionarLocalTela extends StatefulWidget {
  final LatLng centro;
  final LatLng? posicaoAtual;

  const _SelecionarLocalTela({required this.centro, this.posicaoAtual});

  @override
  State<_SelecionarLocalTela> createState() => _SelecionarLocalTelaState();
}

class _SelecionarLocalTelaState extends State<_SelecionarLocalTela> {
  LatLng? _marcado;
  bool _satelite = false;

  static const _urlRua =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}';
  static const _urlSatelite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const _urlSateliteOverlay =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';
  static const _userAgent = 'br.senai.gustavofranco.mapadelocais';

  @override
  void initState() {
    super.initState();
    _marcado = widget.posicaoAtual;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcar local'),
        actions: [
          IconButton(
            tooltip: _satelite ? 'Modo rua' : 'Modo satélite',
            icon: Icon(_satelite ? Icons.map_outlined : Icons.satellite_alt),
            onPressed: () => setState(() => _satelite = !_satelite),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.centro,
              initialZoom: 15,
              minZoom: 4,
              maxZoom: 18,
              onTap: (_, ponto) => setState(() => _marcado = ponto),
            ),
            children: [
              if (_satelite) ...[
                TileLayer(
                  urlTemplate: _urlSatelite,
                  userAgentPackageName: _userAgent,
                  maxZoom: 18,
                ),
                TileLayer(
                  urlTemplate: _urlSateliteOverlay,
                  userAgentPackageName: _userAgent,
                  maxZoom: 18,
                ),
              ] else
                TileLayer(
                  urlTemplate: _urlRua,
                  userAgentPackageName: _userAgent,
                  maxZoom: 18,
                ),
              if (_marcado != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _marcado!,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.location_on,
                        color: cs.primary,
                        size: 48,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Instrução no topo
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.touch_app, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _marcado == null
                            ? 'Toque no mapa onde fica o local'
                            : 'Local marcado! Toque em outro ponto para mudar.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed:
                _marcado == null ? null : () => Navigator.pop(context, _marcado),
            icon: const Icon(Icons.check),
            label: const Text('Confirmar local'),
          ),
        ),
      ),
    );
  }
}
