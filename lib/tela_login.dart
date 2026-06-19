import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_cadastro.dart';
import 'tela_funcionario_principal.dart';
import 'tela_principal.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final formKey = GlobalKey<FormState>();
  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;
  bool obscureText = true;

  Future<void> fazerLogin() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final data = await Supabase.instance.client
          .from('usuario')
          .select()
          .eq('nome', usuarioController.text.trim())
          .eq('senha', senhaController.text.trim())
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        final profissional = await Supabase.instance.client
            .from('profissionais')
            .select()
            .eq('nome', data['nome']?.toString() ?? '')
            .maybeSingle();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Usuario autenticado com sucesso"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) {
              if (profissional != null) {
                return TelaFuncionarioPrincipal(
                  profissionalId: profissional['id'],
                  profissionalNome: profissional['nome']?.toString() ?? '',
                );
              }

              return TelaPrincipal(
                usuarioNome:
                    data['nome']?.toString() ?? usuarioController.text.trim(),
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Usuario ou senha incorretos"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro de conexao ou RLS: $e")));
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Icon(
                    Icons.content_cut,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    "Barbearia",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2B211E),
                    ),
                  ),
                  TextFormField(
                    controller: usuarioController,
                    decoration: const InputDecoration(
                      labelText: "Usuario",
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
                          onPressed: fazerLogin,
                          child: const Text("Entrar"),
                        ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TelaCadastro()),
                      );
                    },
                    child: const Text("Cadastre-se"),
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
