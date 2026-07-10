import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaFuncionarioHorarios extends StatefulWidget {
  final int profissionalId;

  const TelaFuncionarioHorarios({super.key, required this.profissionalId});

  @override
  State<TelaFuncionarioHorarios> createState() =>
      _TelaFuncionarioHorariosState();
}

class _TelaFuncionarioHorariosState extends State<TelaFuncionarioHorarios> {
  List horarios = [];
  bool carregando = true;
  String? mensagem;

  Color bgBase = Color(0xFF111111);
  Color bgCard = Color(0xFF1A1A1A);
  Color gold = Color(0xFFC9A84C);
  Color goldSutil = Color(0x33C9A84C);
  Color cream = Color(0xFFF5F0E8);
  Color muted = Color(0xFF8C8C8C);

  @override
  void initState() {
    super.initState();
    carregarHorarios();
  }

  Future<void> carregarHorarios() async {
    try {
      final dados = await Supabase.instance.client
          .from('horarios_profissionais')
          .select()
          .eq('profissional_id', widget.profissionalId);

      if (!mounted) return;
      setState(() {
        horarios = dados;
        mensagem = null;
        carregando = false;
      });
    } on PostgrestException {
      if (!mounted) return;
      setState(() {
        mensagem = 'Crie a tabela horarios_profissionais no Supabase';
        carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar horarios: $e');
      if (!mounted) return;
      setState(() {
        mensagem = 'Erro ao carregar horários';
        carregando = false;
      });
    }
  }

  Widget buildHorarioCard(dynamic horario) {
    final dia = horario['dia_semana'] ?? horario['descricao'] ?? '-';
    final inicio = formatarHorarioSalvo(horario['horario_inicio']);
    final fim = formatarHorarioSalvo(horario['horario_fim']);

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldSutil, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 1.5),
                color: Color(0xFF222222),
              ),
              child: Icon(Icons.schedule_outlined, color: gold, size: 20),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    dia.toString(),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cream,
                    ),
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Icon(Icons.access_time_outlined, size: 13, color: muted),
                      Text(
                        '$inicio até $fim',
                        style: GoogleFonts.dmSans(fontSize: 13, color: muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatarHorarioSalvo(dynamic valor) {
    if (valor == null) return '-';

    final texto = valor.toString().trim();
    if (texto.isEmpty) return '-';

    final partes = texto.split(':');
    final hora = int.tryParse(partes.first);
    if (hora == null) return texto;

    final minuto = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    return '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
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
          'Horários',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TelaCadastroHorario(profissionalId: widget.profissionalId),
            ),
          ).then((_) => carregarHorarios());
        },
        backgroundColor: gold,
        foregroundColor: bgBase,
        elevation: 4,
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
        color: gold,
        backgroundColor: bgCard,
        onRefresh: carregarHorarios,
        child: carregando
            ? Center(child: CircularProgressIndicator(color: gold))
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520),
                  child: mensagem != null
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 16,
                                children: [
                                  Icon(
                                    Icons.warning_amber_outlined,
                                    size: 48,
                                    color: muted.withValues(alpha: 0.4),
                                  ),
                                  Text(
                                    mensagem!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : horarios.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 16,
                                children: [
                                  Icon(
                                    Icons.event_busy_outlined,
                                    size: 48,
                                    color: muted.withValues(alpha: 0.4),
                                  ),
                                  Text(
                                    'Nenhum horário cadastrado',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
                          children: horarios
                              .map((h) => buildHorarioCard(h))
                              .toList(),
                        ),
                ),
              ),
      ),
    );
  }
}

class TelaCadastroHorario extends StatefulWidget {
  final int profissionalId;

  const TelaCadastroHorario({super.key, required this.profissionalId});

  @override
  State<TelaCadastroHorario> createState() => _TelaCadastroHorarioState();
}

class _TelaCadastroHorarioState extends State<TelaCadastroHorario> {
  Color bgBase = Color(0xFF111111);
  Color bgCard = Color(0xFF1A1A1A);
  Color gold = Color(0xFFC9A84C);
  Color goldSutil = Color(0x33C9A84C);
  Color cream = Color(0xFFF5F0E8);
  Color muted = Color(0xFF8C8C8C);

  final formKey = GlobalKey<FormState>();
  final dias = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
  TimeOfDay? horarioInicio;
  TimeOfDay? horarioFim;
  String diaSelecionado = 'Segunda';
  String? erroHorario;
  bool salvando = false;

  String formatarHorario(TimeOfDay horario) {
    return '${horario.hour.toString().padLeft(2, '0')}:00';
  }

  String? validarHorariosSelecionados() {
    if (horarioInicio == null || horarioFim == null) {
      return 'Selecione o horário inicial e final';
    }

    if (horarioFim!.hour <= horarioInicio!.hour) {
      return 'Final deve ser maior que inicial';
    }

    return null;
  }

  Future<void> selecionarHorario({
    required bool inicial,
    required String titulo,
  }) async {
    final horarioAtual = inicial ? horarioInicio : horarioFim;
    final horaSelecionada = horarioAtual?.hour;

    final selecionado = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cream,
                  ),
                ),
                SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.15,
                  children: List.generate(24, (hora) {
                    final estaSelecionado = horaSelecionada == hora;

                    return OutlinedButton(
                      onPressed: () => Navigator.pop(context, hora),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: estaSelecionado
                            ? gold
                            : Color(0xFF222222),
                        foregroundColor: estaSelecionado ? bgBase : cream,
                        side: BorderSide(
                          color: estaSelecionado ? gold : goldSutil,
                          width: estaSelecionado ? 1.4 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text('${hora.toString().padLeft(2, '0')}:00'),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selecionado == null || !mounted) return;

    setState(() {
      final horario = TimeOfDay(hour: selecionado, minute: 0);
      if (inicial) {
        horarioInicio = horario;
      } else {
        horarioFim = horario;
      }
      erroHorario = null;
    });
  }

  InputDecoration inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.dmSans(fontSize: 13, color: muted),
      hintStyle: GoogleFonts.dmSans(fontSize: 13, color: muted),
      filled: true,
      fillColor: Color(0xFF222222),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0x33C9A84C), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFE24B4A), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFE24B4A), width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget buildHorarioPicker({
    required String label,
    required String placeholder,
    required TimeOfDay? horario,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final selecionado = horario != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Color(0xFF222222),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? gold : goldSutil,
            width: selecionado ? 1.4 : 1,
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selecionado ? goldSutil : bgCard,
              ),
              child: Icon(icon, color: gold, size: 18),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(fontSize: 12, color: muted),
                  ),
                  Text(
                    selecionado ? formatarHorario(horario) : placeholder,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selecionado ? cream : muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.schedule_outlined, color: selecionado ? gold : muted),
          ],
        ),
      ),
    );
  }

  Widget buildErroHorario() {
    final erro = erroHorario;
    if (erro == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0x22E24B4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE24B4A), width: 0.7),
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(Icons.error_outline, color: Color(0xFFE24B4A), size: 17),
          Expanded(
            child: Text(
              erro,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE24B4A),
              ),
            ),
          ),
        ],
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
          'Novo horário',
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
          child: Form(
            key: formKey,
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
                    spacing: 14,
                    children: [
                      Text(
                        'Informações do horário',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cream,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: diaSelecionado,
                        dropdownColor: bgCard,
                        style: GoogleFonts.dmSans(fontSize: 14, color: cream),
                        iconEnabledColor: gold,
                        decoration: inputDecoration('Dia da semana', ''),
                        items: dias
                            .map(
                              (dia) => DropdownMenuItem(
                                value: dia,
                                child: Text(dia),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => diaSelecionado = value);
                          }
                        },
                        validator: (value) =>
                            value == null ? 'Escolha o dia' : null,
                      ),
                      buildHorarioPicker(
                        label: 'Horário inicial',
                        placeholder: 'Toque para selecionar',
                        horario: horarioInicio,
                        icon: Icons.play_circle_outline,
                        onTap: () => selecionarHorario(
                          inicial: true,
                          titulo: 'Horário inicial',
                        ),
                      ),
                      buildHorarioPicker(
                        label: 'Horário final',
                        placeholder: 'Toque para selecionar',
                        horario: horarioFim,
                        icon: Icons.stop_circle_outlined,
                        onTap: () => selecionarHorario(
                          inicial: false,
                          titulo: 'Horário final',
                        ),
                      ),
                      buildErroHorario(),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: salvando
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            final erro = validarHorariosSelecionados();
                            if (erro != null) {
                              setState(() => erroHorario = erro);
                              return;
                            }

                            final inicio = horarioInicio!.hour;
                            final fim = horarioFim!.hour;

                            setState(() => salvando = true);

                            try {
                              await Supabase.instance.client
                                  .from('horarios_profissionais')
                                  .insert({
                                    'profissional_id': widget.profissionalId,
                                    'dia_semana': diaSelecionado,
                                    'descricao': diaSelecionado,
                                    'horario_inicio': inicio,
                                    'horario_fim': fim,
                                  });

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Horário cadastrado',
                                    style: GoogleFonts.dmSans(color: bgBase),
                                  ),
                                  backgroundColor: Color(0xFF639922),
                                ),
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erro ao salvar horário: $e',
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
                            'Salvar horário',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 12),

                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: salvando
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gold,
                      side: BorderSide(color: Color(0x33C9A84C), width: 1),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
