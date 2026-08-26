import 'package:aula07/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Navega para a segunda tela', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TelaInicial()));

    expect(find.text('Tela Inicial'), findsOneWidget);

    await tester.tap(find.text('Ir para Segunda Tela'));
    await tester.pumpAndSettle();

    expect(find.text('Segunda Tela'), findsOneWidget);
  });
}
