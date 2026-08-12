// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atividade2/main.dart';

void main() {
  testWidgets('Lista de compras - adicionar e marcar item', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: ListaComprasApp()));

    // Verify that the app is loaded
    expect(find.text('🛒 Lista de Compras'), findsOneWidget);
    expect(find.text('Nenhum item na lista'), findsOneWidget);

    // Enter an item
    await tester.enterText(find.byType(TextField), 'Leite');
    await tester.pump();

    // Tap the add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the item was added
    expect(find.text('Leite'), findsOneWidget);

    // Mark item as done
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    // Verify counter updated
    expect(find.text('1/1'), findsOneWidget);
  });
}
