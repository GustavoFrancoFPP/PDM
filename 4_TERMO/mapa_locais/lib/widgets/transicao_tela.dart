import 'package:flutter/material.dart';

// Uma entrada suave deixa as mudanças de tela mais agradáveis.
Route<void> criarRota(Widget tela) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) => tela,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final animacao = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: animacao,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(animacao),
          child: child,
        ),
      );
    },
  );
}
