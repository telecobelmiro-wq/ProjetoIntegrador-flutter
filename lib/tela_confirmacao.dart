import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaConfirmacao extends StatefulWidget {
  final String clienteNome;
  final int profissionalId;
  final int servicoId;
  final String nomeProfissional;
  final String servicoNome;
  final DateTime data;
  final String horario;

  const TelaConfirmacao({
    super.key,
    required this.clienteNome,
    required this.profissionalId,
    required this.servicoId,
    required this.nomeProfissional,
    required this.servicoNome,
    required this.data,
    required this.horario,
  });

  @override
  State<TelaConfirmacao> createState() => _TelaConfirmacaoState();
}

class _TelaConfirmacaoState extends State<TelaConfirmacao> {
  bool salvando = false;

  String get dataParaSalvar {
    final data = widget.data;
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  String get dataFormatada {
    final data = widget.data;
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> confirmarAgendamento() async {
    setState(() {
      salvando = true;
    });

    try {
      await Supabase.instance.client.from('agendamento').insert({
        'cliente_nome': widget.clienteNome,
        'profissional_id': widget.profissionalId,
        'servico_id': widget.servicoId,
        'data_agendamento': dataParaSalvar,
        'horario': widget.horario,
        'status': 'Agendado',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agendamento criado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar agendamento: $e')));
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmacao')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(color: Colors.black87, width: 2),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Text(
                      'Confirmacao',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 2, color: Colors.black87),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoConfirmacao(
                          titulo: 'Profissional:',
                          valor: widget.nomeProfissional,
                        ),
                        const SizedBox(height: 18),
                        _InfoConfirmacao(
                          titulo: 'Servico:',
                          valor: widget.servicoNome,
                        ),
                        const SizedBox(height: 18),
                        _InfoConfirmacao(titulo: 'Data:', valor: dataFormatada),
                        const SizedBox(height: 18),
                        _InfoConfirmacao(
                          titulo: 'Horario:',
                          valor: widget.horario,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: salvando
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: salvando
                                    ? null
                                    : confirmarAgendamento,
                                child: salvando
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      )
                                    : const Text('Confirmar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoConfirmacao extends StatelessWidget {
  final String titulo;
  final String valor;

  const _InfoConfirmacao({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(valor.isEmpty ? '-' : valor, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
