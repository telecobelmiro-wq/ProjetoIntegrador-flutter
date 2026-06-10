import 'package:flutter/material.dart';
import 'main.dart';

class TelaServicos extends StatelessWidget {
  final dynamic idProfissional;
  final String nomeProfissional;

  const TelaServicos({
    super.key,
    required this.idProfissional,
    required this.nomeProfissional,
  });

  Future<List<dynamic>> _buscarServicos() async {
    final dados = await supabase
        .from('servicos')
        .select()
        .eq('profissional_id', idProfissional);
    return dados;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Serviços de $nomeProfissional:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _buscarServicos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum serviço encontrado para este profissional.',
                      ),
                    );
                  }

                  final listaServicos = snapshot.data!;

                  return ListView.builder(
                    itemCount: listaServicos.length,
                    itemBuilder: (context, index) {
                      final servico = listaServicos[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                servico['nome'].toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Duração: ${servico['duracao']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Valor: R\$ ${servico['valor']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
