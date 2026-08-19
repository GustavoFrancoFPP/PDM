import 'package:cadastro_alunos/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formata o total de alunos', () {
    expect(formatarTotalAlunos(0), 'Total de alunos: 0');
    expect(formatarTotalAlunos(5), 'Total de alunos: 5');
  });

  test('valida e-mail simples', () {
    expect(emailValido('aluno@escola.com'), isTrue);
    expect(emailValido('aluno-sem-email'), isFalse);
  });
}
