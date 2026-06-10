import 'package:flutter/material.dart';
import 'main.dart';
import 'tela_servicos.dart';

class TelaProfissional extends StatefulWidget {
  const TelaProfissional({super.key});

  @override
  State<TelaProfissional> createState() => _TelaProfissionalState();
}

class _TelaProfissionalState extends State<TelaProfissional> {
  Map<String, dynamic>? _profissionalSelecionado;
  String _descricaoProfissional =
      "Clique em um profissional para ver os detalhes.";
  bool _mostrarBotaoServicos = false;

  Future<List<dynamic>> _buscarProfissionais() async {
    final dados = await supabase.from('profissionais').select();
    return dados;
  }

  void _selecionarProfissional(Map<String, dynamic> profissional) {
    setState(() {
      _profissionalSelecionado = profissional;
      _descricaoProfissional =
          "Sobre ${profissional['nome']}:\n${profissional['descricao']}";
      _mostrarBotaoServicos = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profissional'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _buscarProfissionais(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Nenhum profissional cadastrado no banco.'),
                    );
                  }

                  final profissionais = snapshot.data!;

                  return ListView.builder(
                    itemCount: profissionais.length,
                    itemBuilder: (context, index) {
                      final p = profissionais[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            p['nome'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Clique para ver detalhes'),
                          onTap: () => _selecionarProfissional(p),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _descricaoProfissional,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            if (_mostrarBotaoServicos)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaServicos(
                        idProfissional: _profissionalSelecionado!['id'],
                        nomeProfissional: _profissionalSelecionado!['nome'],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text(
                  'Ver Serviços Disponíveis',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
