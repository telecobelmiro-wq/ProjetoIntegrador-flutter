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

  Color bgBase = Color(0xFF111111);
  Color bgCard = Color(0xFF1A1A1A);
  Color gold = Color(0xFFC9A84C);
  Color goldSutil = Color(0x33C9A84C);
  Color cream = Color(0xFFF5F0E8);
  Color muted = Color(0xFF8C8C8C);

  String get dataParaSalvar {
    final d = widget.data;
    final ano = d.year.toString().padLeft(4, '0');
    final mes = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  String get dataFormatada {
    final d = widget.data;
    final dia = d.day.toString().padLeft(2, '0');
    final mes = d.month.toString().padLeft(2, '0');
    return '$dia/$mes/${d.year}';
  }

  Widget buildDetalhe(IconData icon, String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: muted)),
            SizedBox(height: 2),
            Text(
              valor.isEmpty ? '-' : valor,
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
    return Scaffold(
      backgroundColor: bgBase,
      appBar: AppBar(
        backgroundColor: bgBase,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text(
          'Confirmação',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 28, 16, 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420),
            child: Column(
              spacing: 28,
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
                        'Resumo do agendamento',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cream,
                        ),
                      ),
                      buildDetalhe(
                        Icons.person_outline,
                        'Cliente',
                        widget.clienteNome,
                      ),
                      Divider(color: goldSutil, thickness: 0.5),
                      buildDetalhe(
                        Icons.content_cut_outlined,
                        'Profissional',
                        widget.nomeProfissional,
                      ),
                      Divider(color: goldSutil, thickness: 0.5),
                      buildDetalhe(
                        Icons.design_services_outlined,
                        'Serviço',
                        widget.servicoNome,
                      ),
                      Divider(color: goldSutil, thickness: 0.5),
                      buildDetalhe(
                        Icons.calendar_today_outlined,
                        'Data',
                        dataFormatada,
                      ),
                      Divider(color: goldSutil, thickness: 0.5),
                      buildDetalhe(
                        Icons.access_time_outlined,
                        'Horário',
                        widget.horario,
                      ),
                    ],
                  ),
                ),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: salvando
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: gold,
                            side: BorderSide(color: goldSutil, width: 1),
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
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: salvando
                              ? null
                              : () async {
                                  setState(() => salvando = true);

                                  try {
                                    await Supabase.instance.client
                                        .from('agendamento')
                                        .insert({
                                          'cliente_nome': widget.clienteNome,
                                          'profissional_id':
                                              widget.profissionalId,
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
                                          style: GoogleFonts.dmSans(
                                            color: bgBase,
                                          ),
                                        ),
                                        backgroundColor: Color(0xFF639922),
                                      ),
                                    );
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao salvar agendamento: $e',
                                          style: GoogleFonts.dmSans(
                                            color: cream,
                                          ),
                                        ),
                                        backgroundColor: Color(0xFFE24B4A),
                                      ),
                                    );
                                  } finally {
                                    if (mounted)
                                      setState(() => salvando = false);
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
