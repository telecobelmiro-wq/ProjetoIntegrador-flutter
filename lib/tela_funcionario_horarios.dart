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

  // ── Cores ────────────────────────────────────────────────────────────────────
  static const Color _bgBase = Color(0xFF111111);
  static const Color _bgCard = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldSutil = Color(0x33C9A84C);
  static const Color _cream = Color(0xFFF5F0E8);
  static const Color _muted = Color(0xFF8C8C8C);

  // ── Lógica (sem alterações) ──────────────────────────────────────────────────
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

  @override
  void initState() {
    super.initState();
    carregarHorarios();
  }

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaCadastroHorario(profissionalId: widget.profissionalId),
      ),
    ).then((_) => carregarHorarios());
  }

  // ── Card de horário ──────────────────────────────────────────────────────────
  Widget _buildHorarioCard(dynamic horario) {
    final dia = horario['dia_semana'] ?? horario['descricao'] ?? '-';
    final inicio = horario['horario_inicio']?.toString() ?? '-';
    final fim = horario['horario_fim']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _goldSutil, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                Icons.schedule_outlined,
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
                    dia.toString(),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _cream,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 13,
                        color: _muted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$inicio até $fim',
                        style: GoogleFonts.dmSans(fontSize: 13, color: _muted),
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
          'Horários',
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

      // ── FAB ──────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCadastro,
        backgroundColor: _gold,
        foregroundColor: _bgBase,
        elevation: 4,
        child: const Icon(Icons.add),
      ),

      // ── Body ─────────────────────────────────────────────────────────────────
      body: RefreshIndicator(
        color: _gold,
        backgroundColor: _bgCard,
        onRefresh: carregarHorarios,
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: mensagem != null
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_outlined,
                                    size: 48,
                                    color: _muted.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    mensagem!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: _muted,
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
                                children: [
                                  Icon(
                                    Icons.event_busy_outlined,
                                    size: 48,
                                    color: _muted.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhum horário cadastrado',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                          children: horarios
                              .map((h) => _buildHorarioCard(h))
                              .toList(),
                        ),
                ),
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// Tela Cadastro Horário
// ════════════════════════════════════════════════════════════════════════════════

class TelaCadastroHorario extends StatefulWidget {
  final int profissionalId;

  const TelaCadastroHorario({super.key, required this.profissionalId});

  @override
  State<TelaCadastroHorario> createState() => _TelaCadastroHorarioState();
}

class _TelaCadastroHorarioState extends State<TelaCadastroHorario> {
  // ── Cores ────────────────────────────────────────────────────────────────────
  static const Color _bgBase = Color(0xFF111111);
  static const Color _bgCard = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldSutil = Color(0x33C9A84C);
  static const Color _cream = Color(0xFFF5F0E8);
  static const Color _muted = Color(0xFF8C8C8C);

  final dias = const [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
  final inicioController = TextEditingController();
  final fimController = TextEditingController();
  String diaSelecionado = 'Segunda';
  bool salvando = false;

  // ── Lógica (sem alterações) ──────────────────────────────────────────────────
  int? lerHora(String texto) {
    return int.tryParse(texto.trim().split(':').first);
  }

  Future<void> salvarHorario() async {
    final inicio = lerHora(inicioController.text);
    final fim = lerHora(fimController.text);

    if (inicio == null || fim == null || inicio >= fim) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Informe um intervalo válido',
            style: GoogleFonts.dmSans(color: _cream),
          ),
          backgroundColor: const Color(0xFFE24B4A),
        ),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      await Supabase.instance.client.from('horarios_profissionais').insert({
        'profissional_id': widget.profissionalId,
        'dia_semana': diaSelecionado,
        'descricao': diaSelecionado,
        'horario_inicio': inicio,
        'horario_fim': fim,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Horário cadastrado',
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
            'Erro ao salvar horário: $e',
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
  void dispose() {
    inicioController.dispose();
    fimController.dispose();
    super.dispose();
  }

  // ── Campo de texto estilizado ────────────────────────────────────────────────
  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.dmSans(fontSize: 13, color: _muted),
      hintStyle: GoogleFonts.dmSans(fontSize: 13, color: _muted),
      filled: true,
      fillColor: const Color(0xFF222222),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x33C9A84C), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _gold, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          'Novo horário',
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
              // ── Card do formulário ─────────────────────────────────────────
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
                      'Informações do horário',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _cream,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown dia
                    DropdownButtonFormField<String>(
                      initialValue: diaSelecionado,
                      dropdownColor: _bgCard,
                      style: GoogleFonts.dmSans(fontSize: 14, color: _cream),
                      iconEnabledColor: _gold,
                      decoration: _inputDecoration('Dia da semana', ''),
                      items: dias
                          .map(
                            (dia) =>
                                DropdownMenuItem(value: dia, child: Text(dia)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => diaSelecionado = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Horário inicial
                    TextFormField(
                      controller: inicioController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.dmSans(fontSize: 14, color: _cream),
                      decoration: _inputDecoration(
                        'Horário inicial',
                        'Ex: 9 ou 09:00',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Horário final
                    TextFormField(
                      controller: fimController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.dmSans(fontSize: 14, color: _cream),
                      decoration: _inputDecoration(
                        'Horário final',
                        'Ex: 18 ou 18:00',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Botão salvar ───────────────────────────────────────────────
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: salvando ? null : salvarHorario,
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
                          'Salvar horário',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Botão cancelar ─────────────────────────────────────────────
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: salvando
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _gold,
                    side: const BorderSide(color: Color(0x33C9A84C), width: 1),
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
    );
  }
}
