import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      setState(() {
        servicos = dados;
        carregando = false;
      });
    } catch (e) {
      debugPrint(e.toString());

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
      appBar: AppBar(title: const Text("Serviços")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: servicos.length,
              itemBuilder: (context, index) {
                final servico = servicos[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),

                    title: Text(
                      servico['nome'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        Text("Duração: ${servico['duracao']}"),

                        Text("Valor: R\$ ${servico['valor']}"),
                      ],
                    ),

                    trailing: const Icon(Icons.arrow_forward_ios),

                    onTap: () {
                      print("Serviço selecionado: ${servico['nome']}");

                      // próxima tela
                    },
                  ),
                );
              },
            ),
    );
  }
}
