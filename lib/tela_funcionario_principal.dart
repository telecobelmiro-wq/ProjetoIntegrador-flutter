import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // ── Cores ────────────────────────────────────────────────────────────────────
  static const Color _bgBase = Color(0xFF111111);
  static const Color _bgCard = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldSutil = Color(0x33C9A84C);
  static const Color _cream = Color(0xFFF5F0E8);
  static const Color _muted = Color(0xFF8C8C8C);

  // ── Lógica (sem alterações) ──────────────────────────────────────────────────
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

  @override
  void initState() {
    super.initState();
    carregarAgendamentos();
  }

  void abrirServicos() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          TelaFuncionarioServicos(profissionalId: widget.profissionalId),
    ),
  );

  void abrirHorarios() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          TelaFuncionarioHorarios(profissionalId: widget.profissionalId),
    ),
  );

  // ── Badge de status ──────────────────────────────────────────────────────────
  Widget _statusBadge(String status) {
    Color cor;
    Color bg;
    switch (status) {
      case 'Concluido':
        cor = const Color(0xFF639922);
        bg = const Color(0xFF639922).withValues(alpha: 0.13);

        break;
      case 'Cancelado':
        cor = const Color(0xFFE24B4A);
        bg = const Color(0x22E24B4A);
        break;
      default:
        cor = _gold;
        bg = _goldSutil;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // ── Card de agendamento ──────────────────────────────────────────────────────
  Widget _buildAgendamentoCard(dynamic agendamento) {
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
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _goldSutil, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold, width: 1.5),
                  color: const Color(0xFF222222),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: _gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _cream,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: _muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          data,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.access_time_outlined,
                          size: 13,
                          color: _muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          horario,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _statusBadge(status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _muted, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _bgCard,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _gold, width: 1.5),
                      color: const Color(0xFF222222),
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      color: _gold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.profissionalNome,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _cream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Área do funcionário',
                    style: GoogleFonts.dmSans(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(
              color: _goldSutil,
              thickness: 0.5,
              indent: 24,
              endIndent: 24,
            ),
            const SizedBox(height: 8),
            _drawerItem(
              icon: Icons.design_services_outlined,
              label: 'Serviços',
              onTap: abrirServicos,
            ),
            _drawerItem(
              icon: Icons.schedule_outlined,
              label: 'Horários',
              onTap: abrirHorarios,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _gold, size: 20),
      title: Text(
        label,
        style: GoogleFonts.dmSans(fontSize: 14, color: _cream),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBase,

      // ── AppBar ───────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _bgBase,
        elevation: 0,
        iconTheme: const IconThemeData(color: _gold),
        title: Text(
          'Painel do funcionário',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _cream,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: _goldSutil, thickness: 0.5, height: 0),
        ),
      ),

      drawer: _buildDrawer(),

      // ── Body ─────────────────────────────────────────────────────────────
      body: RefreshIndicator(
        color: _gold,
        backgroundColor: _bgCard,
        onRefresh: carregarAgendamentos,
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    children: [
                      // ── Card de comissão ──────────────────────────────────
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _gold, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _goldSutil,
                              ),
                              child: const Icon(
                                Icons.payments_outlined,
                                color: _gold,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comissão do mês',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: _muted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'R\$ ${comissao.toStringAsFixed(2)}',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: _gold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Lista de agendamentos ─────────────────────────────
                      if (agendamentos.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy_outlined,
                                size: 48,
                                color: _muted.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum atendimento encontrado',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...agendamentos.map((a) => _buildAgendamentoCard(a)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
