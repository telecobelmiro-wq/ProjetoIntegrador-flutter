import 'dart:convert';
import 'package:crypto/crypto.dart';
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

  // ── Cores da identidade visual ──────────────────────────────────────────────
  static const Color _bgBase = Color(0xFF111111);
  static const Color _bgCard = Color(0xFF1A1A1A);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldSutil = Color(0x33C9A84C); // gold 20% opacidade
  static const Color _cream = Color(0xFFF5F0E8);
  static const Color _muted = Color(0xFF8C8C8C);

  // ── InputDecoration reutilizável ─────────────────────────────────────────────
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
      fillColor: _bgCard,
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

  // ── Lógica de login (sem alterações) ────────────────────────────────────────
  Future<void> fazerLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => carregando = true);

    try {
      final senhaLimpa = senhaController.text.trim();
      final bytesDaSenha = utf8.encode(senhaLimpa);
      final senhaHash = sha256.convert(bytesDaSenha).toString();

      final data = await Supabase.instance.client
          .from('usuario')
          .select()
          .eq('nome', usuarioController.text.trim())
          .eq('senha', senhaHash)
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
          SnackBar(
            content: const Text('Usuário autenticado com sucesso'),
            backgroundColor: const Color(0xFF3B6D11),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
          SnackBar(
            content: const Text('Usuário ou senha incorretos'),
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
          content: Text('Erro de conexão: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => carregando = false);
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
      backgroundColor: _bgBase,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo ────────────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _gold, width: 1.5),
                          color: _bgCard,
                        ),
                        child: const Icon(
                          Icons.content_cut,
                          size: 32,
                          color: _gold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Título ───────────────────────────────────────────────
                    const Text(
                      'Barbearia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily:
                            'PlayfairDisplay', // adicione no pubspec.yaml
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: _cream,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'BEM-VINDO DE VOLTA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _muted,
                        letterSpacing: 2.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Campo usuário ────────────────────────────────────────
                    TextFormField(
                      controller: usuarioController,
                      style: const TextStyle(color: _cream, fontSize: 15),
                      decoration: _inputDecoration(
                        label: 'Usuário',
                        prefixIcon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ── Campo senha ──────────────────────────────────────────
                    TextFormField(
                      controller: senhaController,
                      obscureText: obscureText,
                      style: const TextStyle(color: _cream, fontSize: 15),
                      decoration: _inputDecoration(
                        label: 'Senha',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => obscureText = !obscureText),
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _muted,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── Botão entrar ─────────────────────────────────────────
                    carregando
                        ? const Center(
                            child: CircularProgressIndicator(color: _gold),
                          )
                        : SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: fazerLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: const Color(0xFF1A1A1A),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              child: const Text('Entrar'),
                            ),
                          ),

                    const SizedBox(height: 16),

                    // ── Link cadastro ────────────────────────────────────────
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TelaCadastro(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _gold,
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                      child: const Text('Ainda não tem conta? Cadastre-se'),
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
