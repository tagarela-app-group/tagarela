import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Widget mascot({int cue = 0, bool talking = false, bool still = false}) =>
      MediaQuery(
        data: MediaQueryData(disableAnimations: still),
        child: BubbleMascot(cue: cue, talking: talking),
      );

  testWidgets('parado não anima; só o sinal faz pular, uma vez', (
    tester,
  ) async {
    await tester.pumpComponent(mascot());
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);

    await tester.pumpComponent(mascot(cue: 1));
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('falando mexe a boca até parar de falar', (tester) async {
    await tester.pumpComponent(mascot(talking: true));
    await tester.pump(AppMotion.wordEvery);
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.pumpComponent(mascot());
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('com animação desligada não pula nem fala', (tester) async {
    await tester.pumpComponent(mascot(still: true));
    await tester.pumpComponent(mascot(cue: 1, talking: true, still: true));

    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
