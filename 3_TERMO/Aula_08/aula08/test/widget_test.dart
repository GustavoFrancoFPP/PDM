import 'package:aula08/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Salva texto digitado', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: SalvarTextoApp()));
    await tester.pump();

    expect(find.text('Salvar dados'), findsOneWidget);
    expect(find.text('Digite algo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Salvo: Hello'), findsOneWidget);
  });
}
