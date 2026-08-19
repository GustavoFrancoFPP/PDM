import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String alunosCollection = 'alunos';

final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool emailValido(String email) {
  return _emailRegex.hasMatch(email.trim());
}

String formatarTotalAlunos(int total) {
  return 'Total de alunos: $total';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseError = await _inicializarFirebase();

  runApp(CadastroAlunosApp(firebaseError: firebaseError));
}

Future<String?> _inicializarFirebase() async {
  try {
    await Firebase.initializeApp();
    return null;
  } catch (erro) {
    return erro.toString();
  }
}

class CadastroAlunosApp extends StatelessWidget {
  const CadastroAlunosApp({super.key, this.firebaseError});

  final String? firebaseError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de Alunos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: firebaseError == null
          ? const TelaPrincipal()
          : TelaErroFirebase(erro: firebaseError!),
    );
  }
}

class TelaErroFirebase extends StatelessWidget {
  const TelaErroFirebase({super.key, required this.erro});

  final String erro;

  @override
  Widget build(BuildContext context) {
    final plataforma = kIsWeb ? 'Web' : defaultTargetPlatform.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Alunos')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Firebase nao inicializou',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Este projeto esta configurado para Android pelo arquivo '
                  'google-services.json. Voce esta executando em: $plataforma.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Para usar o CRUD com Firebase, conecte um celular Android '
                  'ou crie/inicie um emulador Android e rode novamente.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SelectableText(
                  erro,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final idadeController = TextEditingController();
  final cursoController = TextEditingController();
  final emailController = TextEditingController();
  final pesquisaController = TextEditingController();

  bool _salvando = false;

  CollectionReference<Map<String, dynamic>> get _alunosRef {
    return FirebaseFirestore.instance.collection(alunosCollection);
  }

  Future<void> cadastrarAluno() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      await _alunosRef.add(
        _dadosAluno(
          nome: nomeController.text,
          idade: idadeController.text,
          curso: cursoController.text,
          email: emailController.text,
          incluirCriadoEm: true,
        ),
      );

      nomeController.clear();
      idadeController.clear();
      cursoController.clear();
      emailController.clear();

      if (!mounted) return;
      _mostrarMensagem('Aluno cadastrado com sucesso!');
    } on FirebaseException catch (erro) {
      if (!mounted) return;
      _mostrarMensagem('Erro ao cadastrar: ${erro.message ?? erro.code}');
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem('Nao foi possivel cadastrar o aluno.');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> abrirEdicao(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) async {
    final aluno = documento.data();
    final nomeEdicao = TextEditingController(text: _texto(aluno, 'nome'));
    final idadeEdicao = TextEditingController(text: _texto(aluno, 'idade'));
    final cursoEdicao = TextEditingController(text: _texto(aluno, 'curso'));
    final emailEdicao = TextEditingController(text: _texto(aluno, 'email'));
    final formEdicaoKey = GlobalKey<FormState>();

    final salvo = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool salvandoEdicao = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Editar aluno'),
              content: SingleChildScrollView(
                child: Form(
                  key: formEdicaoKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _campoFormulario(
                        controller: nomeEdicao,
                        label: 'Nome',
                        icon: Icons.person_outline,
                        validator: (valor) =>
                            _validarObrigatorio(valor, 'o nome'),
                      ),
                      _campoFormulario(
                        controller: idadeEdicao,
                        label: 'Idade',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: _validarIdade,
                      ),
                      _campoFormulario(
                        controller: cursoEdicao,
                        label: 'Curso',
                        icon: Icons.school_outlined,
                        validator: (valor) =>
                            _validarObrigatorio(valor, 'o curso'),
                      ),
                      _campoFormulario(
                        controller: emailEdicao,
                        label: 'E-mail',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validarEmail,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: salvandoEdicao
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  onPressed: salvandoEdicao
                      ? null
                      : () async {
                          if (!formEdicaoKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() => salvandoEdicao = true);

                          try {
                            await documento.reference.update(
                              _dadosAluno(
                                nome: nomeEdicao.text,
                                idade: idadeEdicao.text,
                                curso: cursoEdicao.text,
                                email: emailEdicao.text,
                              ),
                            );

                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop(true);
                          } on FirebaseException catch (erro) {
                            if (!mounted || !dialogContext.mounted) return;
                            setDialogState(() => salvandoEdicao = false);
                            _mostrarMensagem(
                              'Erro ao editar: ${erro.message ?? erro.code}',
                            );
                          } catch (_) {
                            if (!mounted || !dialogContext.mounted) return;
                            setDialogState(() => salvandoEdicao = false);
                            _mostrarMensagem(
                              'Nao foi possivel editar o aluno.',
                            );
                          }
                        },
                  icon: salvandoEdicao
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    nomeEdicao.dispose();
    idadeEdicao.dispose();
    cursoEdicao.dispose();
    emailEdicao.dispose();

    if (!mounted) return;

    if (salvo == true) {
      _mostrarMensagem('Aluno atualizado com sucesso!');
    }
  }

  Future<void> confirmarExclusao(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) async {
    final aluno = documento.data();

    final deveExcluir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir aluno'),
          content: Text('Deseja realmente excluir ${_texto(aluno, 'nome')}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (deveExcluir != true) {
      return;
    }

    try {
      await documento.reference.delete();

      if (!mounted) return;
      _mostrarMensagem('Aluno excluido com sucesso!');
    } on FirebaseException catch (erro) {
      if (!mounted) return;
      _mostrarMensagem('Erro ao excluir: ${erro.message ?? erro.code}');
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem('Nao foi possivel excluir o aluno.');
    }
  }

  Map<String, dynamic> _dadosAluno({
    required String nome,
    required String idade,
    required String curso,
    required String email,
    bool incluirCriadoEm = false,
  }) {
    final nomeTratado = nome.trim();
    final dados = <String, dynamic>{
      'nome': nomeTratado,
      'nomeBusca': nomeTratado.toLowerCase(),
      'idade': int.parse(idade.trim()),
      'curso': curso.trim(),
      'email': email.trim(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };

    if (incluirCriadoEm) {
      dados['criadoEm'] = FieldValue.serverTimestamp();
    }

    return dados;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filtrarAlunos(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> alunos,
  ) {
    final busca = pesquisaController.text.trim().toLowerCase();
    final alunosFiltrados =
        alunos.where((documento) {
          final dados = documento.data();
          final nome = _texto(dados, 'nome').toLowerCase();
          return busca.isEmpty || nome.contains(busca);
        }).toList()..sort((a, b) {
          final nomeA = _texto(a.data(), 'nome').toLowerCase();
          final nomeB = _texto(b.data(), 'nome').toLowerCase();
          return nomeA.compareTo(nomeB);
        });

    return alunosFiltrados;
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  void dispose() {
    nomeController.dispose();
    idadeController.dispose();
    cursoController.dispose();
    emailController.dispose();
    pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Alunos'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _campoFormulario(
                      controller: nomeController,
                      label: 'Nome',
                      icon: Icons.person_outline,
                      validator: (valor) =>
                          _validarObrigatorio(valor, 'o nome'),
                    ),
                    _campoFormulario(
                      controller: idadeController,
                      label: 'Idade',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: _validarIdade,
                    ),
                    _campoFormulario(
                      controller: cursoController,
                      label: 'Curso',
                      icon: Icons.school_outlined,
                      validator: (valor) =>
                          _validarObrigatorio(valor, 'o curso'),
                    ),
                    _campoFormulario(
                      controller: emailController,
                      label: 'E-mail',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validarEmail,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _salvando ? null : cadastrarAluno,
                        icon: _salvando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: const Text('Cadastrar aluno'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: pesquisaController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Pesquisar aluno',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: pesquisaController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar pesquisa',
                          onPressed: () {
                            pesquisaController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _alunosRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Erro ao carregar alunos: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final todosAlunos = snapshot.data?.docs ?? [];
                  final alunos = _filtrarAlunos(todosAlunos);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          formatarTotalAlunos(todosAlunos.length),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (todosAlunos.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text('Nenhum aluno cadastrado ainda.'),
                          ),
                        )
                      else if (alunos.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text('Nenhum aluno encontrado.'),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemCount: alunos.length,
                            itemBuilder: (context, index) {
                              return _cartaoAluno(alunos[index]);
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoAluno(QueryDocumentSnapshot<Map<String, dynamic>> documento) {
    final aluno = documento.data();
    final nome = _texto(aluno, 'nome');
    final idade = _texto(aluno, 'idade');
    final curso = _texto(aluno, 'curso');
    final email = _texto(aluno, 'email');
    final emailExibido = email.isEmpty ? 'nao informado' : email;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(child: Text(_iniciais(nome))),
        title: Text(nome, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Idade: $idade anos\nCurso: $curso\nE-mail: $emailExibido',
          ),
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 0,
          children: [
            IconButton(
              tooltip: 'Editar',
              onPressed: () => abrirEdicao(documento),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Excluir',
              onPressed: () => confirmarExclusao(documento),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoFormulario({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  String? _validarObrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe $campo.';
    }

    return null;
  }

  String? _validarIdade(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe a idade.';
    }

    final idade = int.tryParse(valor.trim());

    if (idade == null || idade <= 0) {
      return 'Informe uma idade valida.';
    }

    if (idade > 120) {
      return 'Confira a idade informada.';
    }

    return null;
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o e-mail.';
    }

    if (!emailValido(valor)) {
      return 'Informe um e-mail valido.';
    }

    return null;
  }
}

String _texto(Map<String, dynamic> dados, String campo) {
  final valor = dados[campo];

  if (valor == null) {
    return '';
  }

  return valor.toString();
}

String _iniciais(String nome) {
  final partes = nome.trim().split(RegExp(r'\s+'));

  if (partes.isEmpty || partes.first.isEmpty) {
    return '?';
  }

  final primeira = partes.first[0];
  final segunda = partes.length > 1 && partes[1].isNotEmpty ? partes[1][0] : '';

  return (primeira + segunda).toUpperCase();
}
