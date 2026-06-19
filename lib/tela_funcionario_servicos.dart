import 'package:flutter/material.dart';
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

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaCadastroServico(profissionalId: widget.profissionalId),
      ),
    ).then((_) => carregarServicos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicos')),
      body: RefreshIndicator.adaptive(
        onRefresh: carregarServicos,
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: servicos.isEmpty
                      ? const Center(child: Text('Nenhum servico cadastrado'))
                      : ListView.builder(
                          itemCount: servicos.length,
                          itemBuilder: (context, index) {
                            final servico = servicos[index];
                            return Card(
                              child: ListTile(
                                title: Text(servico['nome']?.toString() ?? '-'),
                                subtitle: Text(
                                  'Duracao: ${servico['duracao'] ?? '-'}\n'
                                  'Valor: R\$ ${servico['valor'] ?? '-'}',
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCadastro,
        child: const Icon(Icons.add),
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

  Future<void> salvarServico() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      await Supabase.instance.client.from('servicos').insert({
        'nome': descricaoController.text.trim(),
        'descricao': descricaoController.text.trim(),
        'duracao': duracaoController.text.trim(),
        'valor': double.tryParse(valorController.text.replaceAll(',', '.')),
        'profissional_id': widget.profissionalId,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servico cadastrado'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar servico: $e')));
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    duracaoController.dispose();
    valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro servico')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  TextFormField(
                    controller: descricaoController,
                    decoration: const InputDecoration(labelText: 'Descricao'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe a descricao'
                        : null,
                  ),
                  TextFormField(
                    controller: duracaoController,
                    decoration: const InputDecoration(labelText: 'Duracao'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe a duracao'
                        : null,
                  ),
                  TextFormField(
                    controller: valorController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Valor'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o valor'
                        : null,
                  ),
                  ElevatedButton(
                    onPressed: salvando ? null : salvarServico,
                    child: salvando
                        ? const CircularProgressIndicator()
                        : const Text('Confirmar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
