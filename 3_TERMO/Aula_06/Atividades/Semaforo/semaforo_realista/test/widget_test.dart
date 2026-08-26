import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semaforo_realista/main.dart';

void main() {
  testWidgets('Muda o estado do semaforo', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SemaforoApp()));

    expect(find.text('PEDESTRE: AGUARDE'), findsOneWidget);
    expect(find.byIcon(Icons.pan_tool), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('PEDESTRE: AGUARDE'), findsOneWidget);
  });
}
