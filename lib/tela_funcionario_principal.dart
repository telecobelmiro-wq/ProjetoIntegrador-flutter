import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_detalhes_servico.dart';
import 'tela_funcionario_horarios.dart';
import 'tela_funcionario_servicos.dart';
import 'tela_login.dart';

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

  Color bgBase = Color(0xFF111111);
  Color bgCard = Color(0xFF1A1A1A);
  Color gold = Color(0xFFC9A84C);
  Color goldSutil = Color(0x33C9A84C);
  Color cream = Color(0xFFF5F0E8);
  Color muted = Color(0xFF8C8C8C);

  @override
  void initState() {
    super.initState();
    carregarAgendamentos();
  }

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
      setState(() => carregando = false);
    }
  }

  Widget statusBadge(String status) {
    Color cor;
    Color bg;
    switch (status) {
      case 'Concluido':
        cor = Color(0xFF639922);
        bg = Color(0xFF639922).withValues(alpha: 0.13);
        break;
      case 'Cancelado':
        cor = Color(0xFFE24B4A);
        bg = Color(0x22E24B4A);
        break;
      default:
        cor = gold;
        bg = goldSutil;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        status,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget buildAgendamentoCard(dynamic agendamento) {
    final cliente = agendamento['cliente_nome']?.toString() ?? 'Cliente';
    final data = agendamento['data_agendamento']?.toString() ?? '-';
    final horario = agendamento['horario']?.toString() ?? '-';
    final status = agendamento['status']?.toString() ?? '-';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TelaDetalhesServico(agendamento: agendamento),
          ),
        ).then((_) => carregarAgendamentos());
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: goldSutil, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 1.5),
                  color: Color(0xFF222222),
                ),
                child: Icon(
                  Icons.event_available_outlined,
                  color: gold,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      cliente,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cream,
                      ),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: muted,
                        ),
                        Text(
                          data,
                          style: GoogleFonts.dmSans(fontSize: 13, color: muted),
                        ),
                        SizedBox(width: 7),
                        Icon(
                          Icons.access_time_outlined,
                          size: 13,
                          color: muted,
                        ),
                        Text(
                          horario,
                          style: GoogleFonts.dmSans(fontSize: 13, color: muted),
                        ),
                      ],
                    ),
                    statusBadge(status),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: muted, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBase,
      appBar: AppBar(
        backgroundColor: bgBase,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text(
          'Painel do funcionário',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cream,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: goldSutil, thickness: 0.5, height: 0),
        ),
      ),
      drawer: Drawer(
        backgroundColor: bgCard,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Center(
                child: Column(
                  spacing: 4,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 1.5),
                        color: Color(0xFF222222),
                      ),
                      child: Icon(Icons.content_cut, color: gold, size: 28),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.profissionalNome,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: cream,
                      ),
                    ),
                    Text(
                      'Área do funcionário',
                      style: GoogleFonts.dmSans(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Divider(
                color: goldSutil,
                thickness: 0.5,
                indent: 24,
                endIndent: 24,
              ),
              SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.design_services_outlined,
                  color: gold,
                  size: 20,
                ),
                title: Text(
                  'Serviços',
                  style: GoogleFonts.dmSans(fontSize: 14, color: cream),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TelaFuncionarioServicos(
                      profissionalId: widget.profissionalId,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.schedule_outlined, color: gold, size: 20),
                title: Text(
                  'Horários',
                  style: GoogleFonts.dmSans(fontSize: 14, color: cream),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TelaFuncionarioHorarios(
                      profissionalId: widget.profissionalId,
                    ),
                  ),
                ),
              ),
              Spacer(),
              Divider(
                color: goldSutil,
                thickness: 0.5,
                indent: 24,
                endIndent: 24,
              ),
              ListTile(
                leading: Icon(Icons.logout, color: gold, size: 20),
                title: Text(
                  'Sair da conta',
                  style: GoogleFonts.dmSans(fontSize: 14, color: cream),
                ),
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => TelaLogin()),
                    (route) => false,
                  );
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: gold,
        backgroundColor: bgCard,
        onRefresh: carregarAgendamentos,
        child: carregando
            ? Center(child: CircularProgressIndicator(color: gold))
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: gold, width: 1),
                        ),
                        child: Row(
                          spacing: 16,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: goldSutil,
                              ),
                              child: Icon(
                                Icons.payments_outlined,
                                color: gold,
                                size: 22,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  'Comissão do mês',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: muted,
                                  ),
                                ),
                                Text(
                                  'R\$ ${comissao.toStringAsFixed(2)}',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: gold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (agendamentos.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Column(
                            spacing: 16,
                            children: [
                              Icon(
                                Icons.event_busy_outlined,
                                size: 48,
                                color: muted.withValues(alpha: 0.4),
                              ),
                              Text(
                                'Nenhum atendimento encontrado',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...agendamentos.map((a) => buildAgendamentoCard(a)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
