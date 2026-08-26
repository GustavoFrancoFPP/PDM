import 'package:exercicio1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Adiciona uma tarefa', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Nenhuma tarefa'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Estudar');
    await tester.tap(find.text('Adicionar'));
    await tester.pump();

    expect(find.text('Estudar'), findsOneWidget);
  });
}
