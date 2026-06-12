import 'package:flutter/material.dart';
import 'tela_principal.dart';

class TelaLogin extends StatelessWidget {
  TelaLogin({super.key});

  final usuario = TextEditingController();
  final senha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Barbearia",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: usuario,
                decoration: const InputDecoration(
                  labelText: "Usuário",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: senha,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaPrincipal()),
                  );
                },
                child: const Text("Entrar"),
              ),

              TextButton(onPressed: () {}, child: const Text("Cadastre-se")),
            ],
          ),
        ),
      ),
    );
  }
}
