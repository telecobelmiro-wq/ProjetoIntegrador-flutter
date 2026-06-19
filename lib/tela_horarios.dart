import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_confirmacao.dart';

class TelaHorarios extends StatefulWidget {
  final String clienteNome;
  final int profissionalId;
  final String nomeProfissional;
  final int servicoId;
  final String servicoNome;
  final String duracao;

  const TelaHorarios({
    super.key,
    required this.clienteNome,
    required this.profissionalId,
    required this.nomeProfissional,
    required this.servicoId,
    required this.servicoNome,
    required this.duracao,
  });

  @override
  State<TelaHorarios> createState() => _TelaHorariosState();
}

class _TelaHorariosState extends State<TelaHorarios> {
  DateTime? dataSelecionada;
  List<String> horarios = [];
  bool carregandoHorarios = false;
  String? mensagemHorarios;

  String obterDiaSemana(DateTime data) {
    const dias = [
      'Segunda',
      'Terca',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sabado',
      'Domingo',
    ];
    return dias[data.weekday - 1];
  }

  String normalizarTexto(String texto) {
    return texto
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u');
  }

  String dataParaConsulta(DateTime data) {
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  int duracaoEmMinutos() {
    final numeros = RegExp(r'\d+')
        .allMatches(widget.duracao)
        .map((match) => int.tryParse(match.group(0) ?? ''))
        .whereType<int>()
        .toList();

    if (numeros.isEmpty) {
      return 30;
    }

    final texto = widget.duracao.toLowerCase();
    if (texto.contains('h')) {
      final horas = numeros.first;
      final minutos = numeros.length > 1 ? numeros[1] : 0;
      return (horas * 60) + minutos;
    }

    return numeros.first;
  }

  int obterHora(dynamic valor) {
    if (valor is int) {
      return valor;
    }

    final texto = valor.toString();
    return int.tryParse(texto.split(':').first) ?? 0;
  }

  String obterDiaHorario(dynamic horarioFuncionamento) {
    return (horarioFuncionamento['dia_semana'] ??
            horarioFuncionamento['descricao'] ??
            '')
        .toString();
  }

  String normalizarHorario(dynamic horario) {
    final texto = horario.toString();
    if (texto.length >= 5) {
      return texto.substring(0, 5);
    }
    return texto;
  }

  List<String> gerarHorarios(dynamic horarioFuncionamento) {
    final inicio = obterHora(horarioFuncionamento['horario_inicio']);
    final fim = obterHora(horarioFuncionamento['horario_fim']);
    final duracao = duracaoEmMinutos();
    final inicioMinutos = inicio * 60;
    final fimMinutos = fim * 60;
    final lista = <String>[];

    for (
      var minuto = inicioMinutos;
      minuto + duracao <= fimMinutos;
      minuto += duracao
    ) {
      final hora = minuto ~/ 60;
      final minutos = minuto % 60;
      lista.add(
        '${hora.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}',
      );
    }

    return lista;
  }

  Future<void> carregarHorarios() async {
    final data = dataSelecionada;
    if (data == null) {
      return;
    }

    setState(() {
      carregandoHorarios = true;
      horarios = [];
      mensagemHorarios = null;
    });

    try {
      final diaSemana = obterDiaSemana(data);
      final dados = await Supabase.instance.client
          .from('horarios_profissionais')
          .select()
          .eq('profissional_id', widget.profissionalId);
      final horariosDoDia = dados.where(
        (horario) =>
            normalizarTexto(obterDiaHorario(horario)) ==
            normalizarTexto(diaSemana),
      );
      final agendamentosDoDia = await Supabase.instance.client
          .from('agendamento')
          .select('horario')
          .eq('profissional_id', widget.profissionalId)
          .eq('data_agendamento', dataParaConsulta(data))
          .eq('status', 'Agendado');
      final horariosOcupados = agendamentosDoDia
          .map((agendamento) => normalizarHorario(agendamento['horario']))
          .toSet();
      final horariosDisponiveis = horariosDoDia
          .expand<String>(gerarHorarios)
          .where((horario) => !horariosOcupados.contains(horario))
          .toList();

      if (!mounted) return;
      setState(() {
        horarios = horariosDisponiveis;
        mensagemHorarios = horariosDisponiveis.isEmpty
            ? 'Nenhum horario disponivel para este profissional nesta data'
            : null;
        carregandoHorarios = false;
      });
    } on PostgrestException catch (e) {
      debugPrint('Erro ao carregar horarios: ${e.message}');
      if (!mounted) return;
      setState(() {
        mensagemHorarios =
            'Cadastre os horarios deste profissional antes de agendar';
        carregandoHorarios = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemHorarios!)));
    } catch (e) {
      debugPrint('Erro ao carregar horarios: $e');
      if (!mounted) return;
      setState(() {
        mensagemHorarios = 'Erro ao carregar horarios do profissional';
        carregandoHorarios = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar horarios do profissional: $e'),
        ),
      );
    }
  }

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: dataSelecionada ?? DateTime.now(),
    );

    if (data != null) {
      setState(() {
        dataSelecionada = data;
      });
      await carregarHorarios();
    }
  }

  void abrirConfirmacao(String horario) {
    if (dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma data primeiro")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaConfirmacao(
          clienteNome: widget.clienteNome,
          profissionalId: widget.profissionalId,
          servicoId: widget.servicoId,
          nomeProfissional: widget.nomeProfissional,
          servicoNome: widget.servicoNome,
          data: dataSelecionada!,
          horario: horario,
        ),
      ),
    );
  }

  String get dataFormatada {
    final data = dataSelecionada;
    if (data == null) {
      return "Escolha uma data";
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return "$dia/$mes/${data.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.servicoNome)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.calendar_month),
                    ),
                    title: Text(dataFormatada),
                    subtitle: Text("Servico: ${widget.servicoNome}"),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: selecionarData,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: carregandoHorarios
                      ? const Center(child: CircularProgressIndicator())
                      : horarios.isEmpty
                      ? Center(
                          child: Text(
                            mensagemHorarios ??
                                "Selecione uma data com horario disponivel",
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: horarios.length,
                          itemBuilder: (context, index) {
                            final horario = horarios[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.schedule),
                                title: Text(horario),
                                subtitle: Text("Duracao: ${widget.duracao}"),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () => abrirConfirmacao(horario),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
