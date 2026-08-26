import 'package:atividade/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Abre detalhes do contato', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TelaInicial()));

    expect(find.text('Contatos'), findsOneWidget);
    expect(find.text('Gustavo'), findsOneWidget);

    await tester.tap(find.text('Gustavo'));
    await tester.pumpAndSettle();

    expect(find.text('Nome: Gustavo'), findsOneWidget);
    expect(find.text('Telefone: 1111-1111'), findsOneWidget);
  });
}
