import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaDetalhesServico extends StatefulWidget {
  final dynamic agendamento;

  const TelaDetalhesServico({super.key, required this.agendamento});

  @override
  State<TelaDetalhesServico> createState() => _TelaDetalhesServicoState();
}

class _TelaDetalhesServicoState extends State<TelaDetalhesServico> {
  String servicoNome = '-';
  bool salvando = false;

  Future<void> carregarServico() async {
    final servicoId = widget.agendamento['servico_id'];
    if (servicoId == null) {
      return;
    }

    try {
      final servico = await Supabase.instance.client
          .from('servicos')
          .select()
          .eq('id', servicoId)
          .maybeSingle();

      if (!mounted || servico == null) return;
      setState(() {
        servicoNome = servico['nome']?.toString() ?? '-';
      });
    } catch (e) {
      debugPrint('Erro ao carregar servico: $e');
    }
  }

  Future<void> finalizarAtendimento() async {
    setState(() {
      salvando = true;
    });

    try {
      await Supabase.instance.client
          .from('agendamento')
          .update({'status': 'Concluido'})
          .eq('id', widget.agendamento['id']);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atendimento finalizado'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao finalizar: $e')));
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    carregarServico();
  }

  @override
  Widget build(BuildContext context) {
    final agendamento = widget.agendamento;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes servico')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Horario: ${agendamento['horario'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Cliente: ${agendamento['cliente_nome'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Servico: $servicoNome'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: salvando ? null : finalizarAtendimento,
                    child: salvando
                        ? const CircularProgressIndicator()
                        : const Text('Finalizar'),
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
