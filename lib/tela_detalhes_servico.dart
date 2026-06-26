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

  Color bgBase = Color(0xFF111111);
  Color bgCard = Color(0xFF1A1A1A);
  Color gold = Color(0xFFC9A84C);
  Color goldSutil = Color(0x33C9A84C);
  Color cream = Color(0xFFF5F0E8);
  Color muted = Color(0xFF8C8C8C);

  @override
  void initState() {
    super.initState();
    carregarServico();
  }

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

  Widget buildDetalhe(IconData icon, String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: goldSutil),
          child: Icon(icon, color: gold, size: 17),
        ),
        SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: muted)),
            Text(
              valor,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: cream,
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
      backgroundColor: bgBase,
      appBar: AppBar(
        backgroundColor: bgBase,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text(
          'Detalhes do atendimento',
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 28, 16, 32),
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: goldSutil, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Text(
                      'Informações',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cream,
                      ),
                    ),
                    buildDetalhe(
                      Icons.person_outline,
                      'Cliente',
                      agendamento['cliente_nome']?.toString() ?? '-',
                    ),
                    Divider(color: goldSutil, thickness: 0.5),
                    buildDetalhe(
                      Icons.content_cut_outlined,
                      'Serviço',
                      servicoNome,
                    ),
                    Divider(color: goldSutil, thickness: 0.5),
                    buildDetalhe(
                      Icons.calendar_today_outlined,
                      'Data',
                      agendamento['data_agendamento']?.toString() ?? '-',
                    ),
                    Divider(color: goldSutil, thickness: 0.5),
                    buildDetalhe(
                      Icons.access_time_outlined,
                      'Horário',
                      agendamento['horario']?.toString() ?? '-',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              if (!jaConcluido)
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: salvando
                        ? null
                        : () async {
                            setState(() => salvando = true);

                            try {
                              await Supabase.instance.client
                                  .from('agendamento')
                                  .update({'status': 'Concluido'})
                                  .eq('id', agendamento['id']);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Atendimento finalizado',
                                    style: GoogleFonts.dmSans(color: bgBase),
                                  ),
                                  backgroundColor: Color(0xFF639922),
                                ),
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erro ao finalizar: $e',
                                    style: GoogleFonts.dmSans(color: cream),
                                  ),
                                  backgroundColor: Color(0xFFE24B4A),
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => salvando = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: bgBase,
                      disabledBackgroundColor: goldSutil,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: salvando
                        ? SizedBox(
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

              if (jaConcluido)
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF639922).withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF639922).withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF639922),
                        size: 18,
                      ),
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
