import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Color bgBase = Color(0xFF111111);
  Color bgCard = Color(0xFF1A1A1A);
  Color gold = Color(0xFFC9A84C);
  Color goldSutil = Color(0x33C9A84C);
  Color cream = Color(0xFFF5F0E8);
  Color muted = Color(0xFF8C8C8C);

  @override
  void dispose() {
    usuarioController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBase,
      appBar: AppBar(
        backgroundColor: bgBase,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text(
          'Criar Conta',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cream,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: goldSutil, thickness: 0.5, height: 0),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 300, maxWidth: 360),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: gold, width: 1.5),
                          color: bgCard,
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          size: 32,
                          color: gold,
                        ),
                      ),
                    ),
                    Text(
                      'Novo Cadastro',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: cream,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'CRIE SUA CONTA',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: muted,
                        letterSpacing: 2.5,
                      ),
                    ),
                    TextFormField(
                      controller: usuarioController,
                      style: TextStyle(color: cream, fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Nome de usuário',
                        labelStyle: TextStyle(color: muted, fontSize: 14),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: gold,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: bgCard,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: goldSutil, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: gold, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFFE24B4A),
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFFE24B4A),
                            width: 1.5,
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
                    TextFormField(
                      controller: senhaController,
                      obscureText: obscureText,
                      style: TextStyle(color: cream, fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: TextStyle(color: muted, fontSize: 14),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: gold,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => obscureText = !obscureText),
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: muted,
                            size: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: bgCard,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: goldSutil, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: gold, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFFE24B4A),
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFFE24B4A),
                            width: 1.5,
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
                    carregando
                        ? Center(child: CircularProgressIndicator(color: gold))
                        : SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                setState(() => carregando = true);

                                try {
                                  final senhaLimpa = senhaController.text
                                      .trim();
                                  final bytes = utf8.encode(senhaLimpa);
                                  final senhaHash = sha256
                                      .convert(bytes)
                                      .toString();

                                  await Supabase.instance.client
                                      .from('usuario')
                                      .insert({
                                        'nome': usuarioController.text.trim(),
                                        'senha': senhaHash,
                                      });

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Usuário cadastrado com sucesso! Faça o login.',
                                      ),
                                      backgroundColor: Color(0xFF3B6D11),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );

                                  Navigator.pop(context);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro ao cadastrar: $e'),
                                      backgroundColor: Color(0xFFA32D2D),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (mounted)
                                    setState(() => carregando = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                foregroundColor: Color(0xFF1A1A1A),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              child: Text('Salvar Cadastro'),
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
