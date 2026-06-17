import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrador_flutter/main.dart';

void main() {
  testWidgets('Mostra a tela de login da barbearia', (tester) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Barbearia'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
