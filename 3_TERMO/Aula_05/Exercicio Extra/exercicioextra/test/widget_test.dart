import 'package:exercicioextra/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Muda o humor exibido', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AlteradorHumorApp()));

    expect(find.text('Eu estou Feliz'), findsOneWidget);

    await tester.tap(find.text('Mudar Humor'));
    await tester.pump();

    expect(find.text('Eu estou Neutro'), findsOneWidget);
  });
}
