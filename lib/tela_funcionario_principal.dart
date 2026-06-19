import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_detalhes_servico.dart';
import 'tela_funcionario_horarios.dart';
import 'tela_funcionario_servicos.dart';

class TelaFuncionarioPrincipal extends StatefulWidget {
  final int profissionalId;
  final String profissionalNome;

  const TelaFuncionarioPrincipal({
    super.key,
    required this.profissionalId,
    required this.profissionalNome,
  });

  @override
  State<TelaFuncionarioPrincipal> createState() =>
      _TelaFuncionarioPrincipalState();
}

class _TelaFuncionarioPrincipalState extends State<TelaFuncionarioPrincipal> {
  List agendamentos = [];
  double comissao = 0;
  bool carregando = true;

  Future<void> carregarAgendamentos() async {
    try {
      final dados = await Supabase.instance.client
          .from('agendamento')
          .select()
          .eq('profissional_id', widget.profissionalId)
          .order('data_agendamento');
      final servicos = await Supabase.instance.client
          .from('servicos')
          .select()
          .eq('profissional_id', widget.profissionalId);

      final servicosPorId = {
        for (final servico in servicos) servico['id']: servico,
      };
      var total = 0.0;
      for (final agendamento in dados) {
        final status = agendamento['status']?.toString();
        final servico = servicosPorId[agendamento['servico_id']];
        if (status == 'Concluido' && servico != null) {
          final valor = double.tryParse(servico['valor'].toString()) ?? 0;
          total += valor * 0.5;
        }
      }

      if (!mounted) return;
      setState(() {
        agendamentos = dados;
        comissao = total;
        carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar tela do funcionario: $e');
      if (!mounted) return;
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarAgendamentos();
  }

  void abrirServicos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaFuncionarioServicos(profissionalId: widget.profissionalId),
      ),
    );
  }

  void abrirHorarios() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaFuncionarioHorarios(profissionalId: widget.profissionalId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Principal')),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.content_cut),
                title: Text(widget.profissionalNome),
                subtitle: const Text('Area do funcionario'),
              ),
              ListTile(
                leading: const Icon(Icons.design_services),
                title: const Text('Servicos'),
                onTap: abrirServicos,
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Horarios'),
                onTap: abrirHorarios,
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: carregarAgendamentos,
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.payments),
                          title: const Text('Comissao do mes'),
                          subtitle: Text('R\$ ${comissao.toStringAsFixed(2)}'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (agendamentos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(
                            child: Text('Nenhum atendimento encontrado'),
                          ),
                        )
                      else
                        ...agendamentos.map(
                          (agendamento) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.event_available),
                              title: Text(
                                agendamento['cliente_nome']?.toString() ??
                                    'Cliente',
                              ),
                              subtitle: Text(
                                '${agendamento['data_agendamento'] ?? '-'}\n'
                                '${agendamento['horario'] ?? '-'}\n'
                                'Status: ${agendamento['status'] ?? '-'}',
                              ),
                              isThreeLine: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TelaDetalhesServico(
                                      agendamento: agendamento,
                                    ),
                                  ),
                                ).then((_) => carregarAgendamentos());
                              },
                            ),
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
