import 'package:app_temperatura/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Aumenta a temperatura', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TemperaturaApp()));

    expect(find.textContaining('20'), findsOneWidget);

    await tester.tap(find.text('+'));
    await tester.pump();

    expect(find.textContaining('21'), findsOneWidget);
  });
}
