import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final novaSenhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool carregando = false;
  bool obscureNovaSenha = true;
  bool obscureConfirmarSenha = true;

  static const Color _bgBase = Color(0xFF111111);
  static const Color _bgCard = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldSutil = Color(0x33C9A84C);
  static const Color _cream = Color(0xFFF5F0E8);
  static const Color _muted = Color(0xFF8C8C8C);

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: _gold, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _bgBase,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _goldSutil, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
      ),
    );
  }

  String? validarEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Informe o e-mail cadastrado';
    }

    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'E-mail inválido';
    }

    return null;
  }

  String? validarNovaSenha(String? value) {
    final senha = value?.trim() ?? '';

    if (senha.isEmpty) {
      return 'Informe a nova senha';
    }

    if (senha.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  String? validarConfirmarSenha(String? value) {
    final confirmar = value?.trim() ?? '';

    if (confirmar.isEmpty) {
      return 'Confirme a nova senha';
    }

    if (confirmar != novaSenhaController.text.trim()) {
      return 'As senhas não conferem';
    }

    return null;
  }

  Future<void> redefinirSenha() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => carregando = true);

    try {
      final email = emailController.text.trim().toLowerCase();
      final novaSenha = novaSenhaController.text.trim();
      final senhaHash = sha256.convert(utf8.encode(novaSenha)).toString();

      final response = await Supabase.instance.client
          .from('usuario')
          .update({'senha': senhaHash})
          .ilike('email', email)
          .select();

      if (!mounted) return;

      if (response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Senha alterada com sucesso!'),
            backgroundColor: const Color(0xFF3B6D11),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('E-mail não encontrado. Verifique o cadastro.'),
            backgroundColor: const Color(0xFFA32D2D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao redefinir a senha: $e'),
          backgroundColor: const Color(0xFFA32D2D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBase,
      appBar: AppBar(
        backgroundColor: _bgBase,
        elevation: 0,
        iconTheme: const IconThemeData(color: _gold),
        title: const Text('Recuperar senha', style: TextStyle(color: _cream)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _goldSutil),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.lock_reset, color: _gold, size: 55),
                          const SizedBox(height: 18),
                          const Text(
                            'Crie uma nova senha',
                            style: TextStyle(
                              color: _cream,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Informe o e-mail cadastrado e defina uma nova senha.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted),
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: _cream, fontSize: 15),
                            decoration: _inputDecoration(
                              label: 'E-mail cadastrado',
                              prefixIcon: Icons.email_outlined,
                            ),
                            validator: validarEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: novaSenhaController,
                            obscureText: obscureNovaSenha,
                            style: const TextStyle(color: _cream, fontSize: 15),
                            decoration: _inputDecoration(
                              label: 'Nova senha',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => obscureNovaSenha = !obscureNovaSenha,
                                ),
                                icon: Icon(
                                  obscureNovaSenha
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: _muted,
                                  size: 20,
                                ),
                              ),
                            ),
                            validator: validarNovaSenha,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: confirmarSenhaController,
                            obscureText: obscureConfirmarSenha,
                            style: const TextStyle(color: _cream, fontSize: 15),
                            decoration: _inputDecoration(
                              label: 'Confirmar senha',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => obscureConfirmarSenha =
                                      !obscureConfirmarSenha,
                                ),
                                icon: Icon(
                                  obscureConfirmarSenha
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: _muted,
                                  size: 20,
                                ),
                              ),
                            ),
                            validator: validarConfirmarSenha,
                          ),
                          const SizedBox(height: 24),
                          carregando
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: _gold,
                                  ),
                                )
                              : SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: redefinirSenha,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _gold,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Salvar nova senha'),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
