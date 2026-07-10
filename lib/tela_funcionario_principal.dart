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
  static const String filtroHoje = 'hoje';
  static const String filtroConcluidos = 'concluidos';
  static const String filtroProximos = 'proximos';

  List agendamentos = [];
  double comissao = 0;
  bool carregando = true;
  String filtroSelecionado = filtroHoje;

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

  DateTime? dataDoAgendamento(dynamic agendamento) {
    final data = DateTime.tryParse(
      agendamento['data_agendamento']?.toString() ?? '',
    );
    return data == null ? null : DateTime(data.year, data.month, data.day);
  }

  List filtrarAgendamentos(String filtro) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    return agendamentos.where((agendamento) {
      final data = dataDoAgendamento(agendamento);
      final status = agendamento['status']?.toString() ?? '';
      final estaAberto = status != 'Concluido' && status != 'Cancelado';

      if (filtro == filtroConcluidos) {
        return status == 'Concluido';
      }

      if (filtro == filtroProximos) {
        return data != null && data.isAfter(hoje) && estaAberto;
      }

      return data != null && data.isAtSameMomentAs(hoje) && estaAberto;
    }).toList();
  }

  Future<void> carregarAgendamentos() async {
    try {
      final supabase = Supabase.instance.client;

      final dados = await supabase
          .from('agendamento')
          .select()
          .eq('profissional_id', widget.profissionalId)
          .order('data_agendamento')
          .order('horario');

      final servicos = await supabase
          .from('servicos')
          .select()
          .eq('profissional_id', widget.profissionalId);

      final servicosPorId = {
        for (final servico in servicos) servico['id']: servico,
      };

      var total = 0.0;
      final listaAgendamentos = [];

      for (final agendamento in dados) {
        listaAgendamentos.add(agendamento);

        final status = agendamento['status']?.toString();
        final servico = servicosPorId[agendamento['servico_id']];

        if (status == 'Concluido' && servico != null) {
          final valor = double.tryParse(servico['valor'].toString()) ?? 0;
          total += valor * 0.5;
        }
      }

      if (!mounted) return;
      setState(() {
        agendamentos = listaAgendamentos;
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

  Widget buildFiltroButton(String filtro, String label, IconData icon) {
    final selecionado = filtroSelecionado == filtro;
    final quantidade = filtrarAgendamentos(filtro).length;

    return GestureDetector(
      onTap: () => setState(() => filtroSelecionado = filtro),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        height: 74,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selecionado ? gold.withValues(alpha: 0.13) : bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selecionado ? gold : goldSutil,
            width: selecionado ? 1.4 : 1,
          ),
        ),
        child: Row(
          spacing: 10,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selecionado ? gold : goldSutil,
              ),
              child: Icon(icon, color: selecionado ? bgBase : gold, size: 18),
            ),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selecionado ? cream : muted,
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(minWidth: 28),
              height: 28,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: selecionado ? gold : Color(0xFF222222),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: goldSutil, width: 0.5),
              ),
              child: Text(
                '$quantidade',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selecionado ? bgBase : gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFiltros() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraItem = constraints.maxWidth >= 460
            ? (constraints.maxWidth - 16) / 3
            : constraints.maxWidth;
        final botoes = [
          buildFiltroButton(filtroHoje, 'Hoje', Icons.today_outlined),
          buildFiltroButton(
            filtroConcluidos,
            'Concluídos',
            Icons.check_circle_outline,
          ),
          buildFiltroButton(
            filtroProximos,
            'Próximos dias',
            Icons.event_note_outlined,
          ),
        ];

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: botoes
              .map((botao) => SizedBox(width: larguraItem, child: botao))
              .toList(),
        );
      },
    );
  }

  Widget buildCabecalhoLista(String titulo, int quantidade) {
    final textoQuantidade = quantidade == 1
        ? '1 serviço'
        : '$quantidade serviços';

    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: GoogleFonts.playfairDisplay(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: cream,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: goldSutil,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldSutil, width: 0.5),
          ),
          child: Text(
            textoQuantidade,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: gold,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEstadoVazioFiltro(String mensagem, IconData icone) {
    return Padding(
      padding: EdgeInsets.only(top: 54),
      child: Column(
        spacing: 16,
        children: [
          Icon(icone, size: 48, color: muted.withValues(alpha: 0.4)),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 15, color: muted),
          ),
        ],
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
    final agendamentosVisiveis = filtrarAgendamentos(filtroSelecionado);
    var tituloFiltro = 'Serviços de hoje';
    var mensagemVazia = 'Nenhum serviço para hoje';
    var iconeVazio = Icons.today_outlined;

    if (filtroSelecionado == filtroConcluidos) {
      tituloFiltro = 'Serviços concluídos';
      mensagemVazia = 'Nenhum serviço concluído ainda';
      iconeVazio = Icons.check_circle_outline;
    } else if (filtroSelecionado == filtroProximos) {
      tituloFiltro = 'Próximos dias';
      mensagemVazia = 'Nenhum serviço marcado para os próximos dias';
      iconeVazio = Icons.event_note_outlined;
    }

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
                  if (!context.mounted) return;
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
                      buildFiltros(),
                      SizedBox(height: 20),
                      buildCabecalhoLista(
                        tituloFiltro,
                        agendamentosVisiveis.length,
                      ),
                      SizedBox(height: 12),
                      if (agendamentosVisiveis.isEmpty)
                        buildEstadoVazioFiltro(mensagemVazia, iconeVazio)
                      else
                        ...agendamentosVisiveis.map(
                          (a) => buildAgendamentoCard(a),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
