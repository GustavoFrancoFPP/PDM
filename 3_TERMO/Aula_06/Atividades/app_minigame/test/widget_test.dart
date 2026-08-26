import 'package:app_minigame/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Mostra o jogo inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: JogoApp()));

    expect(find.text('Pedra Papel Tesoura'), findsOneWidget);
    expect(find.text('Computador'), findsOneWidget);
    expect(find.text('Resetar Placar'), findsOneWidget);
    expect(find.byIcon(Icons.landscape), findsOneWidget);
  });
}
