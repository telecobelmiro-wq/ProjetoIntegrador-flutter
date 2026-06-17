import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_horarios.dart';

class TelaServicos extends StatefulWidget {
  final int profissionalId;
  final String nomeProfissional;

  const TelaServicos({
    super.key,
    required this.profissionalId,
    required this.nomeProfissional,
  });

  @override
  State<TelaServicos> createState() => _TelaServicosState();
}

class _TelaServicosState extends State<TelaServicos> {
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
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarServicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nomeProfissional)),
      body: RefreshIndicator.adaptive(
        onRefresh: carregarServicos,
        child: SizedBox.expand(
          child: carregando
              ? const Center(child: CircularProgressIndicator())
              : servicos.isEmpty
              ? const Center(child: Text("Nenhum servico cadastrado"))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: ListView.builder(
                      itemCount: servicos.length,
                      itemBuilder: (context, index) {
                        final servico = servicos[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TelaHorarios(
                                  profissionalId: widget.profissionalId,
                                  servicoId: servico['id'],
                                  servicoNome: servico['nome'].toString(),
                                  duracao: servico['duracao']?.toString() ?? '',
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
                                child: const Icon(Icons.design_services),
                              ),
                              title: Text(
                                servico['nome'].toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Duracao: ${servico['duracao'] ?? '-'}",
                                    ),
                                    Text(
                                      "Valor: R\$ ${servico['valor'] ?? '-'}",
                                    ),
                                  ],
                                ),
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
