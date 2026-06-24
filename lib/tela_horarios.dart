import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_confirmacao.dart';

// ── Cores ────────────────────────────────────────────────────────────────────
const Color _bgBase = Color(0xFF111111);
const Color _bgCard = Color(0xFF1A1A1A);
const Color _gold = Color(0xFFC9A84C);
const Color _goldSutil = Color(0x33C9A84C);
const Color _cream = Color(0xFFF5F0E8);
const Color _muted = Color(0xFF8C8C8C);

class TelaHorarios extends StatefulWidget {
  final String clienteNome;
  final int profissionalId;
  final String nomeProfissional;
  final int servicoId;
  final String servicoNome;
  final String duracao;

  const TelaHorarios({
    super.key,
    required this.clienteNome,
    required this.profissionalId,
    required this.nomeProfissional,
    required this.servicoId,
    required this.servicoNome,
    required this.duracao,
  });

  @override
  State<TelaHorarios> createState() => _TelaHorariosState();
}

class _TelaHorariosState extends State<TelaHorarios> {
  DateTime? dataSelecionada;
  List<String> horarios = [];
  bool carregandoHorarios = false;
  String? mensagemHorarios;

  // ── Lógica (sem alterações) ──────────────────────────────────────────────────
  String obterDiaSemana(DateTime data) {
    const dias = [
      'Segunda',
      'Terca',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sabado',
      'Domingo',
    ];
    return dias[data.weekday - 1];
  }

  String normalizarTexto(String texto) {
    return texto
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u');
  }

  String dataParaConsulta(DateTime data) {
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  int duracaoEmMinutos() {
    final numeros = RegExp(r'\d+')
        .allMatches(widget.duracao)
        .map((m) => int.tryParse(m.group(0) ?? ''))
        .whereType<int>()
        .toList();
    if (numeros.isEmpty) return 30;
    final texto = widget.duracao.toLowerCase();
    if (texto.contains('h')) {
      final horas = numeros.first;
      final minutos = numeros.length > 1 ? numeros[1] : 0;
      return (horas * 60) + minutos;
    }
    return numeros.first;
  }

  int obterHora(dynamic valor) {
    if (valor is int) return valor;
    final texto = valor.toString();
    return int.tryParse(texto.split(':').first) ?? 0;
  }

  String obterDiaHorario(dynamic h) =>
      (h['dia_semana'] ?? h['descricao'] ?? '').toString();

  String normalizarHorario(dynamic horario) {
    final texto = horario.toString();
    return texto.length >= 5 ? texto.substring(0, 5) : texto;
  }

  List<String> gerarHorarios(dynamic h) {
    final inicio = obterHora(h['horario_inicio']);
    final fim = obterHora(h['horario_fim']);
    final dur = duracaoEmMinutos();
    final lista = <String>[];
    for (var m = inicio * 60; m + dur <= fim * 60; m += dur) {
      lista.add(
        '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}',
      );
    }
    return lista;
  }

  Future<void> carregarHorarios() async {
    final data = dataSelecionada;
    if (data == null) return;

    setState(() {
      carregandoHorarios = true;
      horarios = [];
      mensagemHorarios = null;
    });

    try {
      final diaSemana = obterDiaSemana(data);
      final dados = await Supabase.instance.client
          .from('horarios_profissionais')
          .select()
          .eq('profissional_id', widget.profissionalId);

      final horariosDoDia = dados.where(
        (h) =>
            normalizarTexto(obterDiaHorario(h)) == normalizarTexto(diaSemana),
      );

      final agendamentosDoDia = await Supabase.instance.client
          .from('agendamento')
          .select('horario')
          .eq('profissional_id', widget.profissionalId)
          .eq('data_agendamento', dataParaConsulta(data))
          .eq('status', 'Agendado');

      final horariosOcupados = agendamentosDoDia
          .map((a) => normalizarHorario(a['horario']))
          .toSet();

      final disponiveis = horariosDoDia
          .expand<String>(gerarHorarios)
          .where((h) => !horariosOcupados.contains(h))
          .toList();

      if (!mounted) return;
      setState(() {
        horarios = disponiveis;
        mensagemHorarios = disponiveis.isEmpty
            ? 'Nenhum horário disponível para esta data'
            : null;
        carregandoHorarios = false;
      });
    } on PostgrestException catch (e) {
      debugPrint('Erro ao carregar horarios: ${e.message}');
      if (!mounted) return;
      setState(() {
        mensagemHorarios =
            'Cadastre os horários deste profissional antes de agendar';
        carregandoHorarios = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemHorarios!),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao carregar horarios: $e');
      if (!mounted) return;
      setState(() {
        mensagemHorarios = 'Erro ao carregar horários do profissional';
        carregandoHorarios = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar horários: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: dataSelecionada ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _gold,
              onPrimary: Color(0xFF1A1A1A),
              surface: _bgCard,
              onSurface: _cream,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: _bgCard),
          ),
          child: child!,
        );
      },
    );

    if (data != null) {
      setState(() => dataSelecionada = data);
      await carregarHorarios();
    }
  }

  void abrirConfirmacao(String horario) {
    if (dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione uma data primeiro'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaConfirmacao(
          clienteNome: widget.clienteNome,
          profissionalId: widget.profissionalId,
          servicoId: widget.servicoId,
          nomeProfissional: widget.nomeProfissional,
          servicoNome: widget.servicoNome,
          data: dataSelecionada!,
          horario: horario,
        ),
      ),
    );
  }

  String get dataFormatada {
    final data = dataSelecionada;
    if (data == null) return 'Escolha uma data';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  // ── Card de seleção de data ──────────────────────────────────────────────────
  Widget _buildDataCard() {
    return GestureDetector(
      onTap: selecionarData,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dataSelecionada != null ? _gold : _goldSutil,
            width: dataSelecionada != null ? 1.5 : 1,
          ),
        ),
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
                Icons.calendar_month_outlined,
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
                    dataFormatada,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: dataSelecionada != null ? _cream : _muted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.servicoNome,
                    style: GoogleFonts.dmSans(fontSize: 13, color: _muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_outlined, color: _muted, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Card de horário ──────────────────────────────────────────────────────────
  Widget _buildHorarioCard(String horario) {
    return GestureDetector(
      onTap: () => abrirConfirmacao(horario),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _goldSutil, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _goldSutil,
              ),
              child: const Icon(
                Icons.access_time_outlined,
                color: _gold,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    horario,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _cream,
                    ),
                  ),
                  Text(
                    'Duração: ${widget.duracao}',
                    style: GoogleFonts.dmSans(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: _muted, size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBase,
      appBar: AppBar(
        backgroundColor: _bgBase,
        elevation: 0,
        iconTheme: const IconThemeData(color: _gold),
        title: Text(
          widget.servicoNome,
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              children: [
                _buildDataCard(),
                const SizedBox(height: 20),

                // ── Seção de horários ──────────────────────────────────────
                if (dataSelecionada != null) ...[
                  Row(
                    children: [
                      Text(
                        'Horários disponíveis',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: _muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!carregandoHorarios && horarios.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _goldSutil,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${horarios.length}',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _gold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                Expanded(
                  child: carregandoHorarios
                      ? const Center(
                          child: CircularProgressIndicator(color: _gold),
                        )
                      : horarios.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy_outlined,
                                size: 48,
                                color: _muted.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                mensagemHorarios ??
                                    'Selecione uma data para ver os horários',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: horarios.length,
                          itemBuilder: (context, index) =>
                              _buildHorarioCard(horarios[index]),
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
