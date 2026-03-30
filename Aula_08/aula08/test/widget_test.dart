// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aula08/main.dart';

void main() {
  testWidgets('Salvar texto smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: SalvarTextoApp()));

    // Verify that the app is loaded with the AppBar title.
    expect(find.text('Salvar dados'), findsOneWidget);
    expect(find.text('Digite algo'), findsOneWidget);

    // Enter some text
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();

    // Tap the save button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify that the text was saved
    expect(find.text('Salvo: Hello'), findsOneWidget);
  });
}
