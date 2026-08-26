import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_contatos/main.dart';

void main() {
  testWidgets('Mostra e abre um contato', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ListaContatos()));

    expect(find.text('Lista de Contatos'), findsOneWidget);
    expect(find.text('Maria Santos'), findsOneWidget);

    await tester.tap(find.text('Maria Santos'));
    await tester.pumpAndSettle();

    expect(find.text('Maria Santos'), findsOneWidget);
    expect(find.text('(21) 98888-1111'), findsOneWidget);
  });
}
