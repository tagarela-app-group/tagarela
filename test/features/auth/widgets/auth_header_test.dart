import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/auth/widgets/auth_header.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra título e subtítulo; voltar fecha a tela', (tester) async {
    await tester.pumpComponent(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: AuthHeader(
                  title: 'Nova senha',
                  subtitle: 'Última etapa.',
                ),
              ),
            ),
          ),
          child: const Text('abrir'),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Nova senha'), findsOneWidget);
    expect(find.text('Última etapa.'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthHeader), findsNothing);
  });
}
