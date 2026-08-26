import 'package:flutter_test/flutter_test.dart';
import 'package:meu_app/main.dart';

void main() {
  testWidgets('Mostra a tela inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello World App'), findsOneWidget);
    expect(find.textContaining('Mundo'), findsOneWidget);
  });
}
