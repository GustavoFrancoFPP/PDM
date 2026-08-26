import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statefull_app0/main.dart';

void main() {
  testWidgets('Incrementa o contador', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PaginaContador()));

    expect(find.text('Clique: 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Clique: 1'), findsOneWidget);
  });
}
