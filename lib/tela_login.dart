import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'tela_principal.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _controleEmail = TextEditingController();
  final TextEditingController _controleSenha = TextEditingController();

  String? _mensagemErro;
  bool _carregando = false;

  Future<void> _validarEEntrar() async {
    String email = _controleEmail.text.trim();
    String senha = _controleSenha.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      setState(() {
        _mensagemErro = 'Por favor, preencha todos os campos!';
      });
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      await supabase.auth.signInWithPassword(email: email, password: senha);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaPrincipal()),
        );
      }
    } on AuthException catch (_) {
      setState(() {
        _mensagemErro = 'E-mail ou senha inválidos.';
      });
    } catch (_) {
      setState(() {
        _mensagemErro = 'Não foi possível conectar ao servidor.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controleEmail.dispose();
    _controleSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _controleEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _controleSenha,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                if (_mensagemErro != null)
                  Text(
                    _mensagemErro!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _validarEEntrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Entrar',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Cadastre-se',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
