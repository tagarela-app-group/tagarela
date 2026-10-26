import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Finder dots() => find.descendant(
    of: find.byType(TypingDots),
    matching: find.byType(DecoratedBox),
  );

  testWidgets('três pontos pulando', (tester) async {
    await tester.pumpComponent(const TypingDots(color: Colors.white));

    expect(dots(), findsNWidgets(3));
    await tester.pump(AppMotion.typing ~/ 4);
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('reduzir movimento deixa parado', (tester) async {
    await tester.pumpComponent(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: TypingDots(color: Colors.white),
      ),
    );

    await tester.pump(AppMotion.typing);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
