import 'package:attividade1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Gera numero aleatorio', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PaginaNumerosAleatorios()));

    expect(find.text('Numero: 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(find.textContaining('Numero:'), findsOneWidget);
  });
}
