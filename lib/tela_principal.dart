import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_profissional.dart';

class TelaPrincipal extends StatefulWidget {
  final String usuarioNome;

  const TelaPrincipal({super.key, required this.usuarioNome});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List agendamentos = [];
  bool carregando = true;

  // ── Cores ────────────────────────────────────────────────────────────────────
  static const Color _bgBase = Color(0xFF111111);
  static const Color _bgCard = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldSutil = Color(0x33C9A84C);
  static const Color _cream = Color(0xFFF5F0E8);
  static const Color _muted = Color(0xFF8C8C8C);

  // ── Lógica (sem alterações) ──────────────────────────────────────────────────
  bool agendamentoPertenceAoUsuario(dynamic agendamento) {
    final clienteNome = agendamento['cliente_nome']?.toString().trim();
    final status = agendamento['status']?.toString().trim();
    return clienteNome == widget.usuarioNome.trim() &&
        status == 'Agendado' &&
        agendamento['servico_id'] != null;
  }

  Future<void> carregarAgendamentos() async {
    try {
      final dados = await Supabase.instance.client
          .from('agendamento')
          .select()
          .eq('cliente_nome', widget.usuarioNome)
          .eq('status', 'Agendado')
          .order('data_agendamento');

      if (!mounted) return;
      setState(() {
        agendamentos = dados.where(agendamentoPertenceAoUsuario).toList();
        carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar agendamentos: $e');
      if (!mounted) return;
      setState(() => carregando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    carregarAgendamentos();
  }

  // ── Card de agendamento ──────────────────────────────────────────────────────
  Widget _buildAgendamentoCard(dynamic agendamento) {
    final data = agendamento['data_agendamento']?.toString() ?? '-';
    final horario = agendamento['horario']?.toString() ?? '-';
    final status = agendamento['status']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            // Ícone
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 1.5),
                color: const Color(0xFF222222),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: _gold,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agendamento['cliente_nome']?.toString() ?? 'Cliente',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _cream,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.calendar_today_outlined, data),
                  const SizedBox(height: 4),
                  _infoRow(Icons.access_time_outlined, horario),
                  const SizedBox(height: 8),
                  // Badge de status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _goldSutil,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _gold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _muted),
        const SizedBox(width: 6),
        Text(texto, style: GoogleFonts.dmSans(fontSize: 13, color: _muted)),
      ],
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _bgCard,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 1.5),
                color: const Color(0xFF222222),
              ),
              child: const Icon(Icons.content_cut, color: _gold, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              'Barbearia',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _cream,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Agenda de atendimentos',
              style: GoogleFonts.dmSans(fontSize: 12, color: _muted),
            ),
            const SizedBox(height: 24),
            Divider(
              color: _goldSutil,
              thickness: 0.5,
              indent: 24,
              endIndent: 24,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person_outline, color: _gold, size: 20),
              title: Text(
                widget.usuarioNome,
                style: GoogleFonts.dmSans(fontSize: 14, color: _cream),
              ),
              subtitle: Text(
                'cliente',
                style: GoogleFonts.dmSans(fontSize: 12, color: _muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBase,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _bgBase,
        elevation: 0,
        iconTheme: const IconThemeData(color: _gold),
        title: Text(
          'Meus agendamentos',
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

      // ── Body ───────────────────────────────────────────────────────────────
      body: RefreshIndicator(
        color: _gold,
        backgroundColor: _bgCard,
        onRefresh: carregarAgendamentos,
        child: SizedBox.expand(
          child: carregando
              ? const Center(child: CircularProgressIndicator(color: _gold))
              : agendamentos.isEmpty
              ? ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 48,
                      color: _muted.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum agendamento\nno momento',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: _muted,
                        height: 1.6,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 12, bottom: 80),
                      itemCount: agendamentos.length,
                      itemBuilder: (context, index) =>
                          _buildAgendamentoCard(agendamentos[index]),
                    ),
                  ),
                ),
        ),
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: _gold,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TelaProfissional(clienteNome: widget.usuarioNome),
            ),
          ).then((_) => carregarAgendamentos());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
