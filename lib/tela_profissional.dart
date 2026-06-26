import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_servicos.dart';

class TelaProfissional extends StatefulWidget {
  final String clienteNome;

  const TelaProfissional({super.key, required this.clienteNome});

  @override
  State<TelaProfissional> createState() => _TelaProfissionalState();
}

class _TelaProfissionalState extends State<TelaProfissional> {
  List profissionais = [];
  bool carregando = true;

  Color bgBase = Color(0xFF111111);
  Color bgCard = Color(0xFF1A1A1A);
  Color gold = Color(0xFFC9A84C);
  Color goldSutil = Color(0x33C9A84C);
  Color cream = Color(0xFFF5F0E8);
  Color muted = Color(0xFF8C8C8C);

  Future<void> carregarProfissionais() async {
    try {
      final dados = await Supabase.instance.client
          .from('profissionais')
          .select();

      if (!mounted) return;
      setState(() {
        profissionais = dados;
        carregando = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar profissionais: $e");
      if (!mounted) return;
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarProfissionais();
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
          'Profissionais',
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
      body: RefreshIndicator(
        color: gold,
        backgroundColor: bgCard,
        onRefresh: carregarProfissionais,
        child: carregando
            ? Center(child: CircularProgressIndicator(color: gold))
            : profissionais.isEmpty
            ? Center(
                child: Text(
                  'Nenhum profissional cadastrado',
                  style: GoogleFonts.dmSans(fontSize: 15, color: muted),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
                    itemCount: profissionais.length,
                    itemBuilder: (context, index) {
                      final profissional = profissionais[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TelaServicos(
                                clienteNome: widget.clienteNome,
                                profissionalId: profissional['id'],
                                nomeProfissional: profissional['nome']
                                    .toString(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: goldSutil, width: 1),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
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
                                  child: Icon(
                                    Icons.person_outline,
                                    color: gold,
                                    size: 20,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        profissional['nome'].toString(),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: cream,
                                        ),
                                      ),
                                      Text(
                                        profissional['especialidade']
                                                ?.toString() ??
                                            'Barbeiro',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          color: muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: muted,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
