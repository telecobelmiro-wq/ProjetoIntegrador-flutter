import 'package:flutter/material.dart';

class TelaHorarios extends StatefulWidget {
  final int profissionalId;
  final int servicoId;
  final String servicoNome;
  final String duracao;

  const TelaHorarios({
    super.key,
    required this.profissionalId,
    required this.servicoId,
    required this.servicoNome,
    required this.duracao,
  });

  @override
  State<TelaHorarios> createState() => _TelaHorariosState();
}

class _TelaHorariosState extends State<TelaHorarios> {
  DateTime? dataSelecionada;

  final horarios = [
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.servicoNome)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final data = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  initialDate: DateTime.now(),
                );

                if (data != null) {
                  setState(() {
                    dataSelecionada = data;
                  });
                }
              },
              child: const Text("Selecionar Data"),
            ),

            const SizedBox(height: 20),

            if (dataSelecionada != null)
              Text(
                "Data: ${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}",
              ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: horarios.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(horarios[index]),
                      onTap: () {
                        print("Horário escolhido: ${horarios[index]}");

                        // salvar agendamento
                      },
                    ),
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
