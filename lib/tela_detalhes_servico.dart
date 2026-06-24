import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // ── Cores ────────────────────────────────────────────────────────────────────
  static const Color _bgBase = Color(0xFF111111);
  static const Color _bgCard = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldSutil = Color(0x33C9A84C);
  static const Color _cream = Color(0xFFF5F0E8);
  static const Color _muted = Color(0xFF8C8C8C);

  // ── Lógica (sem alterações) ──────────────────────────────────────────────────
  Future<void> carregarServico() async {
    final servicoId = widget.agendamento['servico_id'];
    if (servicoId == null) return;

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
    setState(() => salvando = true);

    try {
      await Supabase.instance.client
          .from('agendamento')
          .update({'status': 'Concluido'})
          .eq('id', widget.agendamento['id']);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Atendimento finalizado',
            style: GoogleFonts.dmSans(color: _bgBase),
          ),
          backgroundColor: const Color(0xFF639922),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao finalizar: $e',
            style: GoogleFonts.dmSans(color: _cream),
          ),
          backgroundColor: const Color(0xFFE24B4A),
        ),
      );
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    carregarServico();
  }

  // ── Linha de detalhe ─────────────────────────────────────────────────────────
  Widget _buildDetalhe({
    required IconData icon,
    required String label,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _goldSutil),
          child: Icon(icon, color: _gold, size: 17),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: _muted)),
            const SizedBox(height: 2),
            Text(
              valor,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _cream,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final agendamento = widget.agendamento;
    final status = agendamento['status']?.toString() ?? '-';
    final jaConcluido = status == 'Concluido';

    return Scaffold(
      backgroundColor: _bgBase,

      // ── AppBar ───────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _bgBase,
        elevation: 0,
        iconTheme: const IconThemeData(color: _gold),
        title: Text(
          'Detalhes do atendimento',
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

      // ── Body ─────────────────────────────────────────────────────────────────
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
            children: [
              // ── Card de detalhes ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _goldSutil, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _cream,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetalhe(
                      icon: Icons.person_outline,
                      label: 'Cliente',
                      valor: agendamento['cliente_nome']?.toString() ?? '-',
                    ),
                    const SizedBox(height: 16),
                    Divider(color: _goldSutil, thickness: 0.5),
                    const SizedBox(height: 16),
                    _buildDetalhe(
                      icon: Icons.content_cut_outlined,
                      label: 'Serviço',
                      valor: servicoNome,
                    ),
                    const SizedBox(height: 16),
                    Divider(color: _goldSutil, thickness: 0.5),
                    const SizedBox(height: 16),
                    _buildDetalhe(
                      icon: Icons.calendar_today_outlined,
                      label: 'Data',
                      valor: agendamento['data_agendamento']?.toString() ?? '-',
                    ),
                    const SizedBox(height: 16),
                    Divider(color: _goldSutil, thickness: 0.5),
                    const SizedBox(height: 16),
                    _buildDetalhe(
                      icon: Icons.access_time_outlined,
                      label: 'Horário',
                      valor: agendamento['horario']?.toString() ?? '-',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Botão finalizar ────────────────────────────────────────────
              if (!jaConcluido)
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: salvando ? null : finalizarAtendimento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: _bgBase,
                      disabledBackgroundColor: _goldSutil,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: salvando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF111111),
                            ),
                          )
                        : Text(
                            'Finalizar atendimento',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

              // ── Badge de concluído (quando já finalizado) ──────────────────
              if (jaConcluido)
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF639922).withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF639922).withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF639922),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Atendimento concluído',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF639922),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
