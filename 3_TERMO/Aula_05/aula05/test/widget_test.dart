import 'package:aula05/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Alterna o interruptor', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: InterruptorApp()));

    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byIcon(Icons.lightbulb), findsOneWidget);
  });
}
