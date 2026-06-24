import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Cores compartilhadas ─────────────────────────────────────────────────────
const Color _bgBase = Color(0xFF111111);
const Color _bgCard = Color(0xFF1A1A1A);
const Color _gold = Color(0xFFC9A84C);
const Color _goldSutil = Color(0x33C9A84C);
const Color _cream = Color(0xFFF5F0E8);
const Color _muted = Color(0xFF8C8C8C);

InputDecoration _inputDeco({
  required String label,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _muted, fontSize: 14),
    prefixIcon: Icon(icon, color: _gold, size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: _bgCard,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _goldSutil, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _gold, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// TELA DE SERVIÇOS
// ════════════════════════════════════════════════════════════════════════════

class TelaFuncionarioServicos extends StatefulWidget {
  final int profissionalId;

  const TelaFuncionarioServicos({super.key, required this.profissionalId});

  @override
  State<TelaFuncionarioServicos> createState() =>
      _TelaFuncionarioServicosState();
}

class _TelaFuncionarioServicosState extends State<TelaFuncionarioServicos> {
  List servicos = [];
  bool carregando = true;

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
      debugPrint('Erro ao carregar servicos: $e');
      if (!mounted) return;
      setState(() => carregando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    carregarServicos();
  }

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaCadastroServico(profissionalId: widget.profissionalId),
      ),
    ).then((_) => carregarServicos());
  }

  Widget _buildServicoCard(dynamic servico) {
    final nome = servico['nome']?.toString() ?? '-';
    final duracao = servico['duracao']?.toString() ?? '-';
    final valor = servico['valor']?.toString() ?? '-';

    return Container(
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold, width: 1.5),
              color: const Color(0xFF222222),
            ),
            child: const Icon(
              Icons.design_services_outlined,
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
                  nome,
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
                        color: _gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          'Serviços',
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
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: servicos.isEmpty
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
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: _muted,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                          itemCount: servicos.length,
                          itemBuilder: (context, index) =>
                              _buildServicoCard(servicos[index]),
                        ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _gold,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: abrirCadastro,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TELA DE CADASTRO DE SERVIÇO
// ════════════════════════════════════════════════════════════════════════════

class TelaCadastroServico extends StatefulWidget {
  final int profissionalId;

  const TelaCadastroServico({super.key, required this.profissionalId});

  @override
  State<TelaCadastroServico> createState() => _TelaCadastroServicoState();
}

class _TelaCadastroServicoState extends State<TelaCadastroServico> {
  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();
  final duracaoController = TextEditingController();
  final valorController = TextEditingController();
  bool salvando = false;

  Future<void> salvarServico() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => salvando = true);

    try {
      await Supabase.instance.client.from('servicos').insert({
        'nome': descricaoController.text.trim(),
        'descricao': descricaoController.text.trim(),
        'duracao': duracaoController.text.trim(),
        'valor': double.tryParse(valorController.text.replaceAll(',', '.')),
        'profissional_id': widget.profissionalId,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Serviço cadastrado com sucesso'),
          backgroundColor: const Color(0xFF3B6D11),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar serviço: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    duracaoController.dispose();
    valorController.dispose();
    super.dispose();
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
          'Novo serviço',
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
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Ícone decorativo ─────────────────────────────────
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _gold, width: 1.5),
                          color: _bgCard,
                        ),
                        child: const Icon(
                          Icons.design_services_outlined,
                          color: _gold,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Campos ───────────────────────────────────────────
                    TextFormField(
                      controller: descricaoController,
                      style: const TextStyle(color: _cream, fontSize: 15),
                      decoration: _inputDeco(
                        label: 'Descrição',
                        icon: Icons.edit_outlined,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe a descrição'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: duracaoController,
                      style: const TextStyle(color: _cream, fontSize: 15),
                      decoration: _inputDeco(
                        label: 'Duração (ex: 30 min)',
                        icon: Icons.access_time_outlined,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe a duração'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: _cream, fontSize: 15),
                      decoration: _inputDeco(
                        label: 'Valor (R\$)',
                        icon: Icons.attach_money_outlined,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe o valor'
                          : null,
                    ),
                    const SizedBox(height: 28),

                    // ── Botão salvar ─────────────────────────────────────
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: salvando ? null : salvarServico,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: const Color(0xFF1A1A1A),
                          disabledBackgroundColor: _goldSutil,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: salvando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: _gold,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
