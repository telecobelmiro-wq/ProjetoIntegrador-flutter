import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text("Profissionais")),
      body: RefreshIndicator.adaptive(
        onRefresh: carregarProfissionais,
        child: SizedBox.expand(
          child: carregando
              ? const Center(child: CircularProgressIndicator())
              : profissionais.isEmpty
              ? const Center(child: Text("Nenhum profissional cadastrado"))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: ListView.builder(
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
                          child: Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.white,
                                child: const Icon(Icons.person),
                              ),
                              title: Text(
                                profissional['nome'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                profissional['especialidade']?.toString() ??
                                    'Barbeiro',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
