import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaHorarios extends StatefulWidget {
  final int profissionalId;
  final int servicoId;
  final String servicoNome;
  final String duracao;

  const TelaHorarios({
    super.key,
    required this.profissionalId,
    required this.servicoId,
    required this.servicoNome,
    required this.duracao,
  });

  @override
  State<TelaHorarios> createState() => _TelaHorariosState();
}

class _TelaHorariosState extends State<TelaHorarios> {
  DateTime? dataSelecionada;
  bool salvando = false;

  final horarios = [
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
  ];

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
    }
  }

  Future<void> salvarHorario(String horario) async {
    if (dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma data primeiro")),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      await Supabase.instance.client.from('agendamento').insert({
        'cliente_nome': 'Cliente',
        'profissional_id': widget.profissionalId,
        'servico_id': widget.servicoId,
        'data_agendamento': dataSelecionada!.toIso8601String(),
        'horario': horario,
        'status': 'Agendado',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Agendamento criado com sucesso"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao salvar agendamento: $e")));
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  String get dataFormatada {
    final data = dataSelecionada;
    if (data == null) {
      return "Escolha uma data";
    }
    return "${data.day}/${data.month}/${data.year}";
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
                  child: ListView.builder(
                    itemCount: horarios.length,
                    itemBuilder: (context, index) {
                      final horario = horarios[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text(horario),
                          subtitle: Text("Duracao: ${widget.duracao}"),
                          trailing: salvando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_ios),
                          onTap: salvando ? null : () => salvarHorario(horario),
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
