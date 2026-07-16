import 'dart:convert';

import 'package:crypto/crypto.dart';

String gerarHashSenha(String senha) {
  return sha256.convert(utf8.encode(senha.trim())).toString();
}

String? validarNomeUsuario(String? value) {
  final nome = value?.trim() ?? '';

  if (nome.isEmpty) {
    return 'Informe o nome';
  }

  if (nome.length < 3) {
    return 'Nome deve ter pelo menos 3 letras';
  }

  if (nome.length > 40) {
    return 'Nome deve ter no máximo 40 caracteres';
  }

  if (RegExp(r'\s{2,}').hasMatch(nome)) {
    return 'Evite espaços repetidos';
  }

  if (!RegExp(r'^[a-zA-ZÀ-ÿ0-9 ]+$').hasMatch(nome)) {
    return 'Use apenas letras e números';
  }

  return null;
}

String? validarEmailUsuario(
  String? value, {
  String mensagemObrigatoria = 'Informe o e-mail',
}) {
  final email = value?.trim() ?? '';

  if (email.isEmpty) {
    return mensagemObrigatoria;
  }

  if (email.length <= 6) {
    return 'E-mail deve ter mais de 6 caracteres';
  }

  if (email.length > 254) {
    return 'E-mail muito longo';
  }

  if (RegExp(r'\s').hasMatch(email)) {
    return 'E-mail não pode ter espaços';
  }

  if ('@'.allMatches(email).length != 1) {
    return 'E-mail deve ter apenas um @';
  }

  final partes = email.split('@');
  final usuario = partes[0];
  final dominio = partes[1];

  if (usuario.isEmpty || dominio.isEmpty) {
    return 'E-mail inválido';
  }

  if (usuario.length > 64) {
    return 'Parte antes do @ é muito longa';
  }

  if (usuario.startsWith('.') ||
      usuario.endsWith('.') ||
      usuario.contains('..')) {
    return 'E-mail inválido';
  }

  if (!RegExp(r'^[a-zA-Z0-9._%+-]+$').hasMatch(usuario)) {
    return 'E-mail contém caracteres inválidos';
  }

  if (dominio.startsWith('.') ||
      dominio.endsWith('.') ||
      dominio.contains('..') ||
      !dominio.contains('.')) {
    return 'Domínio do e-mail inválido';
  }

  final labels = dominio.split('.');
  for (final label in labels) {
    if (label.isEmpty ||
        label.startsWith('-') ||
        label.endsWith('-') ||
        !RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(label)) {
      return 'Domínio do e-mail inválido';
    }
  }

  final extensao = labels.last;
  if (!RegExp(r'^[a-zA-Z]{2,}$').hasMatch(extensao)) {
    return 'Extensão do e-mail inválida';
  }

  return null;
}

String? validarSenhaForte(
  String? value, {
  String mensagemObrigatoria = 'Informe a senha',
}) {
  final senha = value?.trim() ?? '';

  if (senha.isEmpty) {
    return mensagemObrigatoria;
  }

  if (senha.length < 6) {
    return 'Senha deve ter pelo menos 6 caracteres';
  }

  if (RegExp(r'\s').hasMatch(senha)) {
    return 'Senha não pode ter espaços';
  }

  if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(senha)) {
    return 'Senha deve ter pelo menos uma letra';
  }

  if (!RegExp(r'\d').hasMatch(senha)) {
    return 'Senha deve ter pelo menos um número';
  }

  return null;
}
