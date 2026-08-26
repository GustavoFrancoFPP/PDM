import 'package:atividade/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Adiciona nota', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: AppNotas()));
    await tester.pump();

    expect(find.text('Minhas Notas'), findsOneWidget);
    expect(find.text('Nenhuma nota ainda'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Test Note');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Test Note'), findsOneWidget);
  });
}
