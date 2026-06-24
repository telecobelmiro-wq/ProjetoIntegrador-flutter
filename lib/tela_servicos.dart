import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_horarios.dart';

// ── Cores ────────────────────────────────────────────────────────────────────
const Color _bgBase = Color(0xFF111111);
const Color _bgCard = Color(0xFF1A1A1A);
const Color _gold = Color(0xFFC9A84C);
const Color _goldSutil = Color(0x33C9A84C);
const Color _cream = Color(0xFFF5F0E8);
const Color _muted = Color(0xFF8C8C8C);

class TelaServicos extends StatefulWidget {
  final String clienteNome;
  final int profissionalId;
  final String nomeProfissional;

  const TelaServicos({
    super.key,
    required this.clienteNome,
    required this.profissionalId,
    required this.nomeProfissional,
  });

  @override
  State<TelaServicos> createState() => _TelaServicosState();
}

class _TelaServicosState extends State<TelaServicos> {
  List servicos = [];
  bool carregando = true;

  // ── Lógica (sem alterações) ──────────────────────────────────────────────────
  Future<void> carregarServicos() async {
    try {
      final dados = await Supabase.instance.client
          .from('servicos')
          .select()
          .eq('profissional_id', widget.profissionalId);

      if (!mounted) return;
      setState(() {
        servicos = dados;
        carregando = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() => carregando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    carregarServicos();
  }

  // ── Card de serviço ──────────────────────────────────────────────────────────
  Widget _buildServicoCard(dynamic servico) {
    final nome = servico['nome']?.toString() ?? '-';
    final duracao = servico['duracao']?.toString() ?? '-';
    final valor = servico['valor']?.toString() ?? '-';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TelaHorarios(
              clienteNome: widget.clienteNome,
              profissionalId: widget.profissionalId,
              nomeProfissional: widget.nomeProfissional,
              servicoId: servico['id'],
              servicoNome: nome,
              duracao: servico['duracao']?.toString() ?? '',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _goldSutil, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 1.5),
                color: const Color(0xFF222222),
              ),
              child: const Icon(
                Icons.design_services_outlined,
                color: _gold,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _cream,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 13,
                        color: _muted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        duracao,
                        style: GoogleFonts.dmSans(fontSize: 13, color: _muted),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.attach_money_outlined,
                        size: 13,
                        color: _muted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'R\$ $valor',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _gold,
                        ),
                      ),
                    ],
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
          widget.nomeProfissional,
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
      body: RefreshIndicator(
        color: _gold,
        backgroundColor: _bgCard,
        onRefresh: carregarServicos,
        child: SizedBox.expand(
          child: carregando
              ? const Center(child: CircularProgressIndicator(color: _gold))
              : servicos.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 120),
                    Icon(
                      Icons.design_services_outlined,
                      size: 48,
                      color: _muted.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum serviço cadastrado',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(fontSize: 15, color: _muted),
                    ),
                  ],
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      itemCount: servicos.length,
                      itemBuilder: (context, index) =>
                          _buildServicoCard(servicos[index]),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
