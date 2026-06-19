import 'package:supabase_flutter/supabase_flutter.dart';

Future salvarAgendamento({
  required String clienteNome,
  required int profissionalId,
  required int servicoId,
  required String dataAgendamento,
  required String horario,
}) async {
  await Supabase.instance.client.from('agendamento').insert({
    'cliente_nome': clienteNome,
    'profissional_id': profissionalId,
    'servico_id': servicoId,
    'data_agendamento': dataAgendamento,
    'horario': horario,
    'status': 'Agendado',
  });
}
