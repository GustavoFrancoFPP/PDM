import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_pdm/main.dart';

void main() {
  testWidgets('Mostra a tela inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello World app'), findsOneWidget);
    expect(find.textContaining('Mundo'), findsOneWidget);
  });
}
