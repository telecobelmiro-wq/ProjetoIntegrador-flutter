import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaFuncionarioHorarios extends StatefulWidget {
  final int profissionalId;

  const TelaFuncionarioHorarios({super.key, required this.profissionalId});

  @override
  State<TelaFuncionarioHorarios> createState() =>
      _TelaFuncionarioHorariosState();
}

class _TelaFuncionarioHorariosState extends State<TelaFuncionarioHorarios> {
  List horarios = [];
  bool carregando = true;
  String? mensagem;

  Future<void> carregarHorarios() async {
    try {
      final dados = await Supabase.instance.client
          .from('horarios_profissionais')
          .select()
          .eq('profissional_id', widget.profissionalId);

      if (!mounted) return;
      setState(() {
        horarios = dados;
        mensagem = null;
        carregando = false;
      });
    } on PostgrestException {
      if (!mounted) return;
      setState(() {
        mensagem = 'Crie a tabela horarios_profissionais no Supabase';
        carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar horarios: $e');
      if (!mounted) return;
      setState(() {
        mensagem = 'Erro ao carregar horarios';
        carregando = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarHorarios();
  }

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaCadastroHorario(profissionalId: widget.profissionalId),
      ),
    ).then((_) => carregarHorarios());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horarios')),
      body: RefreshIndicator.adaptive(
        onRefresh: carregarHorarios,
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: mensagem != null
                      ? Center(
                          child: Text(mensagem!, textAlign: TextAlign.center),
                        )
                      : horarios.isEmpty
                      ? const Center(child: Text('Nenhum horario cadastrado'))
                      : ListView.builder(
                          itemCount: horarios.length,
                          itemBuilder: (context, index) {
                            final horario = horarios[index];
                            final dia =
                                horario['dia_semana'] ??
                                horario['descricao'] ??
                                '-';
                            return Card(
                              child: ListTile(
                                title: Text(dia.toString()),
                                subtitle: Text(
                                  '${horario['horario_inicio'] ?? '-'} ate ${horario['horario_fim'] ?? '-'}',
                                ),
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

class TelaCadastroHorario extends StatefulWidget {
  final int profissionalId;

  const TelaCadastroHorario({super.key, required this.profissionalId});

  @override
  State<TelaCadastroHorario> createState() => _TelaCadastroHorarioState();
}

class _TelaCadastroHorarioState extends State<TelaCadastroHorario> {
  final dias = const [
    'Segunda',
    'Terca',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sabado',
    'Domingo',
  ];
  final inicioController = TextEditingController();
  final fimController = TextEditingController();
  String diaSelecionado = 'Segunda';
  bool salvando = false;

  int? lerHora(String texto) {
    return int.tryParse(texto.trim().split(':').first);
  }

  Future<void> salvarHorario() async {
    final inicio = lerHora(inicioController.text);
    final fim = lerHora(fimController.text);

    if (inicio == null || fim == null || inicio >= fim) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um intervalo valido')),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      await Supabase.instance.client.from('horarios_profissionais').insert({
        'profissional_id': widget.profissionalId,
        'dia_semana': diaSelecionado,
        'descricao': diaSelecionado,
        'horario_inicio': inicio,
        'horario_fim': fim,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horario cadastrado'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar horario: $e')));
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
    inicioController.dispose();
    fimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro horario')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: diaSelecionado,
                  decoration: const InputDecoration(labelText: 'Dia'),
                  items: dias
                      .map(
                        (dia) => DropdownMenuItem(value: dia, child: Text(dia)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        diaSelecionado = value;
                      });
                    }
                  },
                ),
                TextFormField(
                  controller: inicioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Horario inicial',
                    hintText: 'Ex: 9 ou 09:00',
                  ),
                ),
                TextFormField(
                  controller: fimController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Horario final',
                    hintText: 'Ex: 18 ou 18:00',
                  ),
                ),
                ElevatedButton(
                  onPressed: salvando ? null : salvarHorario,
                  child: salvando
                      ? const CircularProgressIndicator()
                      : const Text('Salvar'),
                ),
                OutlinedButton(
                  onPressed: salvando
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
