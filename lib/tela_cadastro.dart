import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final formKey = GlobalKey<FormState>();
  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;
  bool obscureText = true;

  Future<void> cadastrarUsuario() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      // 1. Pega a senha limpa digitada pelo usuário
      final senhaLimpa = senhaController.text.trim();

      // 2. Transforma a senha em um Hash SHA-256 seguro antes de mandar pro banco
      final bytesDaSenha = utf8.encode(senhaLimpa);
      final senhaHash = sha256.convert(bytesDaSenha).toString();

      // 3. Salva no banco enviando a variável 'senhaHash'
      await Supabase.instance.client.from('usuario').insert({
        'nome': usuarioController.text.trim(),
        'senha': senhaHash, // 👈 Agora vai criptografado!
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario cadastrado com sucesso! Faca o login."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao cadastrar: $e")));
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usuarioController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Icon(
                    Icons.person_add,
                    size: 52,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    "Novo Cadastro",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    controller: usuarioController,
                    decoration: const InputDecoration(
                      labelText: "Nome de usuario",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Campo obrigatorio!";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: senhaController,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Campo obrigatorio!";
                      }
                      return null;
                    },
                  ),
                  carregando
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: cadastrarUsuario,
                          child: const Text("Salvar Cadastro"),
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
