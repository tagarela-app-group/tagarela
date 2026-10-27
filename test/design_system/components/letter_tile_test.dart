import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  BoxDecoration decoration(WidgetTester tester) =>
      tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer))
              .decoration!
          as BoxDecoration;

  testWidgets('cada estado tem sua cor de papel', (tester) async {
    final colors = AppColors.light;
    final expected = {
      LetterTileState.empty: colors.surfaceAlt,
      LetterTileState.active: colors.surfaceAlt,
      LetterTileState.filled: colors.primarySoft,
      LetterTileState.help: colors.learningSoft,
      LetterTileState.wrong: colors.surface,
      LetterTileState.done: colors.primary,
    };
    for (final MapEntry(key: state, value: color) in expected.entries) {
      await tester.pumpComponent(LetterTile(letter: 'a', state: state));
      await tester.pumpAndSettle();

      expect(decoration(tester).color, color, reason: '$state');
    }
  });

  testWidgets('casa ativa e letra errada ganham contorno', (tester) async {
    await tester.pumpComponent(
      const LetterTile(letter: '', state: LetterTileState.active),
    );
    expect(
      (decoration(tester).border! as Border).top.color,
      AppColors.light.primary,
    );

    await tester.pumpComponent(
      const LetterTile(letter: 'x', state: LetterTileState.wrong),
    );
    await tester.pumpAndSettle();
    expect(
      (decoration(tester).border! as Border).top.color,
      AppColors.light.alert,
    );
  });

  testWidgets('virar errada ou certa balança uma vez e para', (tester) async {
    Widget tile(LetterTileState state) => LetterTile(
      key: const ValueKey('tile'),
      letter: 'a',
      state: state,
      delay: const Duration(milliseconds: 90),
    );
    await tester.pumpComponent(tile(LetterTileState.filled));

    await tester.pumpComponent(tile(LetterTileState.done));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('a'), findsOneWidget);
  });
}
