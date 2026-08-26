import 'package:atividade2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Lista de compras - adicionar e marcar item', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: ListaComprasApp()));
    await tester.pump();

    expect(find.text('Lista de Compras (0/0)'), findsOneWidget);
    expect(find.text('Nenhum item na lista'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Leite');
    await tester.tap(find.text('Adicionar'));
    await tester.pump();

    expect(find.text('Leite'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(find.text('Lista de Compras (1/1)'), findsOneWidget);
  });
}
