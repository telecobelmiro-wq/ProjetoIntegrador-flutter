import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // ── Cores ────────────────────────────────────────────────────────────────────
  static const Color _bgBase = Color(0xFF111111);
  static const Color _bgCard = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldSutil = Color(0x33C9A84C);
  static const Color _cream = Color(0xFFF5F0E8);
  static const Color _muted = Color(0xFF8C8C8C);

  // ── Lógica (sem alterações) ──────────────────────────────────────────────────
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
    setState(() => salvando = true);

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
        SnackBar(
          content: Text(
            'Agendamento criado com sucesso',
            style: GoogleFonts.dmSans(color: _bgBase),
          ),
          backgroundColor: const Color(0xFF639922),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar agendamento: $e',
            style: GoogleFonts.dmSans(color: _cream),
          ),
          backgroundColor: const Color(0xFFE24B4A),
        ),
      );
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  // ── Linha de detalhe ─────────────────────────────────────────────────────────
  Widget _buildDetalhe({
    required IconData icon,
    required String label,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _goldSutil,
          ),
          child: Icon(icon, color: _gold, size: 17),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: _muted)),
            const SizedBox(height: 2),
            Text(
              valor.isEmpty ? '-' : valor,
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
    return Scaffold(
      backgroundColor: _bgBase,

      // ── AppBar ───────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _bgBase,
        elevation: 0,
        iconTheme: const IconThemeData(color: _gold),
        title: Text(
          'Confirmação',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // ── Card de resumo ─────────────────────────────────────────
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
                        'Resumo do agendamento',
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
                        valor: widget.clienteNome,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: _goldSutil, thickness: 0.5),
                      const SizedBox(height: 16),

                      _buildDetalhe(
                        icon: Icons.content_cut_outlined,
                        label: 'Profissional',
                        valor: widget.nomeProfissional,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: _goldSutil, thickness: 0.5),
                      const SizedBox(height: 16),

                      _buildDetalhe(
                        icon: Icons.design_services_outlined,
                        label: 'Serviço',
                        valor: widget.servicoNome,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: _goldSutil, thickness: 0.5),
                      const SizedBox(height: 16),

                      _buildDetalhe(
                        icon: Icons.calendar_today_outlined,
                        label: 'Data',
                        valor: dataFormatada,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: _goldSutil, thickness: 0.5),
                      const SizedBox(height: 16),

                      _buildDetalhe(
                        icon: Icons.access_time_outlined,
                        label: 'Horário',
                        valor: widget.horario,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Botões ─────────────────────────────────────────────────
                Row(
                  children: [
                    // Cancelar
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: salvando
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _gold,
                            side: const BorderSide(
                              color: Color(0x33C9A84C),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Confirmar
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: salvando ? null : confirmarAgendamento,
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
                                  'Confirmar',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
