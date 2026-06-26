import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Color bgBase = Color(0xFF111111);
  Color bgCard = Color(0xFF1A1A1A);
  Color gold = Color(0xFFC9A84C);
  Color goldSutil = Color(0x33C9A84C);
  Color cream = Color(0xFFF5F0E8);
  Color muted = Color(0xFF8C8C8C);

  @override
  void initState() {
    super.initState();
    carregarServicos();
  }

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

  Widget buildServicoCard(dynamic servico) {
    final nome = servico['nome']?.toString() ?? '-';
    final duracao = servico['duracao']?.toString() ?? '-';
    final valor = servico['valor']?.toString() ?? '-';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldSutil, width: 1),
      ),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 1.5),
              color: Color(0xFF222222),
            ),
            child: Icon(Icons.design_services_outlined, color: gold, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  nome,
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
                      duracao,
                      style: GoogleFonts.dmSans(fontSize: 13, color: muted),
                    ),
                    SizedBox(width: 9),
                    Icon(Icons.attach_money_outlined, size: 13, color: muted),
                    Text(
                      'R\$ $valor',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: gold,
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
      backgroundColor: bgBase,
      appBar: AppBar(
        backgroundColor: bgBase,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text(
          'Serviços',
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
        backgroundColor: gold,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TelaCadastroServico(profissionalId: widget.profissionalId),
            ),
          ).then((_) => carregarServicos());
        },
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
        color: gold,
        backgroundColor: bgCard,
        onRefresh: carregarServicos,
        child: carregando
            ? Center(child: CircularProgressIndicator(color: gold))
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520),
                  child: servicos.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: 120),
                            Icon(
                              Icons.design_services_outlined,
                              size: 48,
                              color: muted.withValues(alpha: 0.4),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum serviço cadastrado',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: muted,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 80),
                          itemCount: servicos.length,
                          itemBuilder: (context, index) =>
                              buildServicoCard(servicos[index]),
                        ),
                ),
              ),
      ),
    );
  }
}

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

  Color bgBase = Color(0xFF111111);
  Color bgCard = Color(0xFF1A1A1A);
  Color gold = Color(0xFFC9A84C);
  Color goldSutil = Color(0x33C9A84C);
  Color cream = Color(0xFFF5F0E8);
  Color muted = Color(0xFF8C8C8C);

  @override
  void dispose() {
    descricaoController.dispose();
    duracaoController.dispose();
    valorController.dispose();
    super.dispose();
  }

  InputDecoration inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: muted, fontSize: 14),
      prefixIcon: Icon(icon, color: gold, size: 20),
      filled: true,
      fillColor: bgCard,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: goldSutil, width: 1),
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
          'Novo serviço',
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
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: gold, width: 1.5),
                          color: bgCard,
                        ),
                        child: Icon(
                          Icons.design_services_outlined,
                          color: gold,
                          size: 28,
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                    TextFormField(
                      controller: descricaoController,
                      style: TextStyle(color: cream, fontSize: 15),
                      decoration: inputDeco('Descrição', Icons.edit_outlined),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe a descrição'
                          : null,
                    ),
                    TextFormField(
                      controller: duracaoController,
                      style: TextStyle(color: cream, fontSize: 15),
                      decoration: inputDeco(
                        'Duração (ex: 30 min)',
                        Icons.access_time_outlined,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe a duração'
                          : null,
                    ),
                    TextFormField(
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: cream, fontSize: 15),
                      decoration: inputDeco(
                        'Valor (R\$)',
                        Icons.attach_money_outlined,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe o valor'
                          : null,
                    ),
                    SizedBox(height: 14),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: salvando
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                setState(() => salvando = true);

                                try {
                                  await Supabase.instance.client
                                      .from('servicos')
                                      .insert({
                                        'nome': descricaoController.text.trim(),
                                        'descricao': descricaoController.text
                                            .trim(),
                                        'duracao': duracaoController.text
                                            .trim(),
                                        'valor': double.tryParse(
                                          valorController.text.replaceAll(
                                            ',',
                                            '.',
                                          ),
                                        ),
                                        'profissional_id':
                                            widget.profissionalId,
                                      });

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Serviço cadastrado com sucesso',
                                      ),
                                      backgroundColor: Color(0xFF3B6D11),
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
                                      content: Text(
                                        'Erro ao salvar serviço: $e',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (mounted) setState(() => salvando = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Color(0xFF1A1A1A),
                          disabledBackgroundColor: goldSutil,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: salvando
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: gold,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Confirmar'),
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
