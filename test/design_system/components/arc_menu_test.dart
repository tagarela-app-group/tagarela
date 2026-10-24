import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

Future<List<String>> _pumpMenu(WidgetTester tester) async {
  final tapped = <String>[];
  await tester.pumpComponent(
    ArcMenu(
      anchorBottom: 80,
      title: 'O que você ouviu?',
      subtitle: 'Escolha',
      items: [
        for (final (icon, label) in const [
          (AppIcons.camera, 'Câmera'),
          (AppIcons.audio, 'Áudio'),
        ])
          ArcMenuItem(
            icon: icon,
            label: label,
            color: AppPalette.mango,
            onTap: () => tapped.add(label),
          ),
      ],
    ),
  );
  return tapped;
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Adicionar termo'));
  await tester.pumpAndSettle();
}

final _dashedArc = find.descendant(
  of: find.byType(ArcMenu),
  matching: find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter != null,
  ),
);

void main() {
  testWidgets('open() pela key abre o menu', (tester) async {
    final key = GlobalKey<ArcMenuState>();
    await tester.pumpComponent(
      ArcMenu(
        key: key,
        anchorBottom: 80,
        title: 'O que você ouviu?',
        items: [
          ArcMenuItem(
            icon: AppIcons.camera,
            label: 'Câmera',
            color: AppPalette.mango,
            onTap: () {},
          ),
        ],
      ),
    );
    expect(find.text('O que você ouviu?'), findsNothing);

    key.currentState!.open();
    await tester.pumpAndSettle();

    expect(find.text('O que você ouviu?'), findsOneWidget);
    expect(find.text('Câmera'), findsOneWidget);
  });

  testWidgets('+ com traço grosso e ponta redonda, como no mockup', (
    tester,
  ) async {
    await _pumpMenu(tester);

    final bars = tester
        .widgetList<Container>(
          find.descendant(
            of: find.bySemanticsLabel('Adicionar termo'),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.constraints!.maxWidth * 10 + c.constraints!.maxHeight);
    expect(bars, unorderedEquals([20 * 10 + 2.8, 2.8 * 10 + 20]));
  });

  testWidgets('fechado mostra só o botão +', (tester) async {
    await _pumpMenu(tester);

    expect(find.bySemanticsLabel('Adicionar termo'), findsOneWidget);
    expect(find.text('Câmera'), findsNothing);
    expect(find.text('O que você ouviu?'), findsNothing);
  });

  testWidgets('toque no + abre opções e título', (tester) async {
    await _pumpMenu(tester);
    await _open(tester);

    expect(find.text('Câmera'), findsOneWidget);
    expect(find.text('Áudio'), findsOneWidget);
    expect(find.text('O que você ouviu?'), findsOneWidget);
    expect(find.text('Escolha'), findsOneWidget);
    expect(find.bySemanticsLabel('Fechar menu'), findsOneWidget);
  });

  testWidgets('aberto desfoca o fundo e liga as opções com arco tracejado', (
    tester,
  ) async {
    await _pumpMenu(tester);
    expect(find.byType(BackdropFilter), findsNothing);
    expect(_dashedArc, findsNothing);

    await _open(tester);

    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(
      tester.renderObject(_dashedArc),
      paints
        ..arc()
        ..arc()
        ..arc(),
    );
  });

  testWidgets('escolher opção chama onTap e fecha', (tester) async {
    final tapped = await _pumpMenu(tester);
    await _open(tester);

    await tester.tap(find.byIcon(AppIcons.audio));
    await tester.pumpAndSettle();

    expect(tapped, ['Áudio']);
    expect(find.text('Áudio'), findsNothing);
  });

  testWidgets('toque no scrim fecha', (tester) async {
    await _pumpMenu(tester);
    await _open(tester);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Câmera'), findsNothing);
  });

  testWidgets('voltar do sistema fecha o menu em vez da tela', (tester) async {
    await _pumpMenu(tester);
    await _open(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Câmera'), findsNothing);
    expect(find.byType(ArcMenu), findsOneWidget);
  });

  testWidgets('fechado deixa toques passarem para baixo', (tester) async {
    var taps = 0;
    tester.useTallScreen();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: TextButton(
                  onPressed: () => taps++,
                  child: const Text('Embaixo'),
                ),
              ),
              Positioned.fill(
                child: ArcMenu(
                  anchorBottom: 80,
                  items: [
                    ArcMenuItem(
                      icon: AppIcons.text,
                      label: 'Texto',
                      color: AppPalette.mint,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Embaixo'));
    expect(taps, 1);
  });
}
