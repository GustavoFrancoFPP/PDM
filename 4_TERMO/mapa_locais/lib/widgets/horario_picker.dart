import 'package:flutter/material.dart';

const _nomesDias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

// Separa "Seg: 08:00-18:00 | Dom: Fechado" em uma lista (dia, horário).
// Retorna vazio se o texto estiver em outro formato.
List<(String, String)> horarioPorDia(String horario) {
  final dias = <(String, String)>[];
  for (final parte in horario.split('|')) {
    final idx = parte.indexOf(':');
    if (idx < 0) continue;
    final dia = parte.substring(0, idx).trim();
    if (!_nomesDias.contains(dia)) continue;
    dias.add((dia, parte.substring(idx + 1).trim().replaceAll('-', ' – ')));
  }
  return dias;
}

// Diz se o local está aberto agora e qual o horário de hoje.
// Retorna null quando o horário não está no formato padrão.
({bool aberto, String horarioHoje})? situacaoAgora(String horario) {
  final dias = horarioPorDia(horario);
  if (dias.isEmpty) return null;
  final agora = DateTime.now();
  final hoje = _nomesDias[agora.weekday - 1];
  for (final (dia, valor) in dias) {
    if (dia != hoje) continue;
    if (valor == 'Fechado') return (aberto: false, horarioHoje: 'Fechado hoje');
    final partes = valor.split(' – ');
    if (partes.length != 2) return null;
    int minutos(String hhmm) {
      final p = hhmm.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }
    final atual = agora.hour * 60 + agora.minute;
    final aberto = atual >= minutos(partes[0]) && atual <= minutos(partes[1]);
    return (aberto: aberto, horarioHoje: valor);
  }
  return null;
}

// Texto curto com o horário de hoje, para mostrar nos cartões.
String resumoHorarioHoje(String horario) {
  final dias = horarioPorDia(horario);
  if (dias.isEmpty) return horario;
  final hoje = _nomesDias[DateTime.now().weekday - 1];
  for (final (dia, valor) in dias) {
    if (dia == hoje) {
      return valor == 'Fechado' ? 'Fechado hoje' : 'Hoje · $valor';
    }
  }
  return horario;
}

class _DiaDados {
  bool aberto = false;
  TimeOfDay abertura = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay fechamento = const TimeOfDay(hour: 18, minute: 0);
}

// Widget para selecionar horário de funcionamento por dia da semana.
class HorarioPicker extends StatefulWidget {
  final String valorInicial;
  final ValueChanged<String> onChanged;

  const HorarioPicker({
    super.key,
    required this.valorInicial,
    required this.onChanged,
  });

  @override
  State<HorarioPicker> createState() => _HorarioPickerState();
}

class _HorarioPickerState extends State<HorarioPicker> {
  late final List<_DiaDados> _dias;

  @override
  void initState() {
    super.initState();
    _dias = List.generate(7, (_) => _DiaDados());
    _parsear(widget.valorInicial);
  }

  // Tenta parsear o formato "Seg: 08:00-18:00 | Dom: Fechado | ..."
  void _parsear(String texto) {
    for (final parte in texto.split('|').map((s) => s.trim())) {
      final colonIdx = parte.indexOf(':');
      if (colonIdx < 0) continue;
      final diaStr = parte.substring(0, colonIdx).trim();
      final resto = parte.substring(colonIdx + 1).trim();
      final idx = _nomesDias.indexOf(diaStr);
      if (idx < 0) continue;
      if (resto.toLowerCase() == 'fechado') {
        _dias[idx].aberto = false;
      } else {
        final partes = resto.split('-');
        if (partes.length == 2) {
          final abertura = _parseTime(partes[0].trim());
          final fechamento = _parseTime(partes[1].trim());
          if (abertura != null && fechamento != null) {
            _dias[idx].aberto = true;
            _dias[idx].abertura = abertura;
            _dias[idx].fechamento = fechamento;
          }
        }
      }
    }
  }

  TimeOfDay? _parseTime(String s) {
    final partes = s.split(':');
    if (partes.length != 2) return null;
    final h = int.tryParse(partes[0]);
    final m = int.tryParse(partes[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatar() {
    return List.generate(7, (i) {
      final d = _dias[i];
      if (!d.aberto) return '${_nomesDias[i]}: Fechado';
      return '${_nomesDias[i]}: ${_fmtT(d.abertura)}-${_fmtT(d.fechamento)}';
    }).join(' | ');
  }

  String _fmtT(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _notificar() => widget.onChanged(_formatar());

  Future<void> _escolherHora(int i, bool isAbertura) async {
    final atual = isAbertura ? _dias[i].abertura : _dias[i].fechamento;
    final result = await showTimePicker(
      context: context,
      initialTime: atual,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (isAbertura) {
        _dias[i].abertura = result;
      } else {
        _dias[i].fechamento = result;
      }
    });
    _notificar();
  }

  void _copiarParaTodos(int diaRef) {
    final ref = _dias[diaRef];
    setState(() {
      for (var i = 0; i < 7; i++) {
        if (i == diaRef) continue;
        _dias[i].aberto = ref.aberto;
        _dias[i].abertura = ref.abertura;
        _dias[i].fechamento = ref.fechamento;
      }
    });
    _notificar();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(7, (i) {
        final dia = _dias[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Text(
                  _nomesDias[i],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Switch(
                value: dia.aberto,
                onChanged: (v) {
                  setState(() => dia.aberto = v);
                  _notificar();
                },
              ),
              Expanded(
                child: dia.aberto
                    ? Row(
                        children: [
                          _btnHora(i, true, _fmtT(dia.abertura)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text('–', style: TextStyle(fontSize: 13)),
                          ),
                          _btnHora(i, false, _fmtT(dia.fechamento)),
                          const Spacer(),
                          IconButton(
                            iconSize: 16,
                            icon: const Icon(Icons.content_copy),
                            tooltip: 'Aplicar para todos os dias',
                            onPressed: () => _copiarParaTodos(i),
                          ),
                        ],
                      )
                    : Text(
                        'Fechado',
                        style: TextStyle(color: cs.outline, fontSize: 13),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _btnHora(int i, bool isAbertura, String label) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        minimumSize: const Size(60, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13),
      ),
      onPressed: () => _escolherHora(i, isAbertura),
      child: Text(label),
    );
  }
}
