import 'package:cadastro_alunos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Mostra o formulario de cadastro', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'alunos': <String>[]});

    await tester.pumpWidget(const MaterialApp(home: CadastroAlunosApp()));
    await tester.pump();

    expect(find.text('Cadastro de Alunos'), findsOneWidget);
    expect(find.text('Nome do Aluno'), findsOneWidget);
    expect(find.text('Cadastrar Aluno'), findsOneWidget);
  });
}
