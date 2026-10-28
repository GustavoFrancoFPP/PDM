import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'favoritos_screen.dart';
import 'mapa_screen.dart';
import 'perfil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  // Cada aba tem a sua própria pilha de telas, assim a barra inferior
  // continua visível em Resultados e Detalhes, como no wireframe.
  final _navegadores = List.generate(3, (_) => GlobalKey<NavigatorState>());

  static const _telas = [MapaScreen(), FavoritosScreen(), PerfilScreen()];

  void _selecionarAba(int i) {
    if (i == _index) {
      // Tocar de novo na aba atual volta para a tela inicial dela.
      _navegadores[i].currentState?.popUntil((rota) => rota.isFirst);
    } else {
      setState(() => _index = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _navegadores[_index].currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else if (_index != 0) {
          setState(() => _index = 0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: List.generate(
            _telas.length,
            (i) => Navigator(
              key: _navegadores[i],
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (_) => _telas[i]),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _selecionarAba,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Mapa',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
