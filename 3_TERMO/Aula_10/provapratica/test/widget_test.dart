import 'package:flutter_test/flutter_test.dart';
import 'package:provapratica/main.dart';

void main() {
  test('Cria o widget principal da prova pratica', () {
    expect(const MyApp(), isA<MyApp>());
  });
}
