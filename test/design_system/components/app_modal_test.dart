import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester, {ThemeData? theme}) async {
    await tester.pumpComponent(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => AppModal.show<void>(
            context,
            (_) => const AppModal(
              icon: AppIcons.text,
              accent: AppAccent.mint,
              title: 'Digitar texto',
              subtitle: 'O que você ouviu ou leu hoje',
              child: Text('conteúdo'),
            ),
          ),
          child: const Text('abrir'),
        ),
      ),
      theme: theme,
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('sobe de baixo com ícone, título, subtítulo e conteúdo', (
    tester,
  ) async {
    await open(tester);

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Digitar texto'), findsOneWidget);
    expect(find.text('O que você ouviu ou leu hoje'), findsOneWidget);
    expect(find.text('conteúdo'), findsOneWidget);
    expect(
      tester.widget<IconTile>(find.byType(IconTile)).accent,
      AppAccent.mint,
    );
  });

  testWidgets('Fechar tira o painel', (tester) async {
    await open(tester);

    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    expect(find.byType(AppModal), findsNothing);
  });

  testWidgets('monta no tema escuro', (tester) async {
    await open(tester, theme: AppTheme.dark);

    expect(tester.takeException(), isNull);
    expect(find.byType(AppModal), findsOneWidget);
  });

  testWidgets('sem ícone: só título e subtítulo; conteúdo longo rola', (
    tester,
  ) async {
    await tester.pumpComponent(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => AppModal.show<void>(
            context,
            (_) => AppModal(
              title: 'Mover pra qual grupo?',
              subtitle: '2 termos de Viagem',
              child: Column(
                children: [
                  for (var i = 0; i < 40; i++)
                    SizedBox(height: 80, child: Text('linha $i')),
                ],
              ),
            ),
          ),
          child: const Text('abrir'),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Mover pra qual grupo?'), findsOneWidget);
    expect(find.byType(IconTile), findsNothing);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
