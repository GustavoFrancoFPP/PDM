import 'package:flutter_test/flutter_test.dart';

import 'package:mapa_locais/main.dart';

void main() {
  testWidgets('app loads with map screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Mapa de locais'), findsOneWidget);
    expect(find.text('Tela do mapa'), findsOneWidget);
  });
}
