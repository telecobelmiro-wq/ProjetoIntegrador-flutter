import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_servicos.dart';

class TelaProfissional extends StatefulWidget {
  const TelaProfissional({super.key});

  @override
  State<TelaProfissional> createState() => _TelaProfissionalState();
}

class _TelaProfissionalState extends State<TelaProfissional> {
  List profissionais = [];

  Future<void> carregarProfissionais() async {
    try {
      final dados = await Supabase.instance.client
          .from('profissionais')
          .select();

      setState(() {
        profissionais = dados;
      });
    } catch (e) {
      print("Erro ao carregar profissionais: $e");
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
      body: ListView.builder(
        itemCount: profissionais.length,
        itemBuilder: (context, index) {
          final p = profissionais[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(p['nome'].toString()),
              subtitle: Text(p['especialidade']?.toString() ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TelaServicos(
                      profissionalId: p['id'],
                      nomeProfissional: p['nome'].toString(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
