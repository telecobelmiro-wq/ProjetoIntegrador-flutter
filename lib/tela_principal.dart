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

  Future<void> carregarAgendamentos() async {
    try {
      final dados = await Supabase.instance.client
          .from('agendamento')
          .select()
          .order('data_agendamento');

      setState(() {
        agendamentos = dados;
      });
    } catch (e) {
      debugPrint("Erro ao carregar agendamentos: $e");
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

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaProfissional()),
          ).then((_) => carregarAgendamentos());
        },
      ),

      body: agendamentos.isEmpty
          ? const Center(
              child: Text(
                "Nenhum agendamento encontrado",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: agendamentos.length,
              itemBuilder: (context, index) {
                final agendamento = agendamentos[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),

                    title: Text(agendamento['cliente_nome'].toString()),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Data: ${agendamento['data_agendamento']}"),
                        Text("Horário: ${agendamento['horario']}"),
                        Text("Status: ${agendamento['status']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
