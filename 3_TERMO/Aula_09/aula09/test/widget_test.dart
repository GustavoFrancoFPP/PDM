import 'package:aula09/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cria o widget principal do banco', () {
    expect(const MyApp(), isA<MyApp>());
  });
}
