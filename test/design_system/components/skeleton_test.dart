import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  double opacity(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find.descendant(
          of: find.byType(Skeleton),
          matching: find.byType(FadeTransition),
        ),
      )
      .opacity
      .value;

  testWidgets('pulsa enquanto está na tela', (tester) async {
    await tester.pumpComponent(const Skeleton(width: 80));

    expect(tester.getSize(find.byType(Skeleton)), const Size(80, 14));
    await tester.pump(AppMotion.pulse);
    expect(opacity(tester), lessThan(1));
  });

  testWidgets('reduzir movimento deixa parado', (tester) async {
    await tester.pumpComponent(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Skeleton(),
      ),
    );

    await tester.pump(AppMotion.pulse);
    expect(opacity(tester), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
