import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bnrqtxnyjhgdjfcwemsw.supabase.co',
    anonKey: 'sb_publishable_yzT4gY1wEOUinmBQMALn_A_gMs8Q9oU',
  );

  runApp(const MeuAplicativo());
}

final supabase = Supabase.instance.client;

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TelaLogin(),
    );
  }
}
