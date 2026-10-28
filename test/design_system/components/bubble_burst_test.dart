import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('solta os balões uma vez e some', (tester) async {
    await tester.pumpComponent(
      const SizedBox.square(dimension: 300, child: BubbleBurst()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(drawnIcon(DrawnGlyph.bubble), findsNWidgets(4));

    await tester.pumpAndSettle();

    expect(drawnIcon(DrawnGlyph.bubble), findsNothing);
  });

  testWidgets('com animação desligada não mostra nada', (tester) async {
    await tester.pumpComponent(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: BubbleBurst(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(drawnIcon(DrawnGlyph.bubble), findsNothing);
  });
}
