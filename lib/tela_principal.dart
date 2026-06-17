import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_profissional.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List agendamentos = [];
  bool carregando = true;

  Future<void> carregarAgendamentos() async {
    try {
      final dados = await Supabase.instance.client
          .from('agendamento')
          .select()
          .order('data_agendamento');

      if (!mounted) return;
      setState(() {
        agendamentos = dados;
        carregando = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar agendamentos: $e");
      if (!mounted) return;
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarAgendamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meus Agendamentos")),
      drawer: const Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.content_cut),
                title: Text("Barbearia"),
                subtitle: Text("Agenda de atendimentos"),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: carregarAgendamentos,
        child: SizedBox.expand(
          child: carregando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: agendamentos.isEmpty
                          ? const Center(
                              child: Text(
                                "Voce nao possui agendamentos no momento",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 520,
                                ),
                                child: ListView.builder(
                                  itemCount: agendamentos.length,
                                  itemBuilder: (context, index) {
                                    final agendamento = agendamentos[index];

                                    return Card(
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(
                                          16,
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          child: const Icon(
                                            Icons.calendar_month,
                                          ),
                                        ),
                                        title: Text(
                                          agendamento['cliente_nome']
                                                  ?.toString() ??
                                              "Cliente",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Data: ${agendamento['data_agendamento'] ?? '-'}",
                                              ),
                                              Text(
                                                "Horario: ${agendamento['horario'] ?? '-'}",
                                              ),
                                              Text(
                                                "Status: ${agendamento['status'] ?? '-'}",
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
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TelaProfissional(),
                          ),
                        ).then((_) => carregarAgendamentos());
                      },
                      child: Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: double.infinity,
                        child: const Text(
                          "Agendar horario",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaProfissional()),
          ).then((_) => carregarAgendamentos());
        },
      ),
    );
  }
}
