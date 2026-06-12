import 'package:supabase_flutter/supabase_flutter.dart';

Future salvarAgendamento(int profissionalId, int servicoId) async {
  await Supabase.instance.client.from('agendamento').insert({
    'cliente': 'Thalis',
    'profissional_id': profissionalId,
    'servico_id': servicoId,
    'status': 'Agendado',
  });
}
