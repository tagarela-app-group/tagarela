import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool flipped}) =>
      tester.pumpComponent(
        FlipCard(
          flipped: flipped,
          front: const SizedBox(height: 80, child: Text('frente')),
          back: const SizedBox(height: 120, child: Text('verso')),
        ),
      );

  testWidgets('mostra a frente com a altura dela', (tester) async {
    await pump(tester, flipped: false);

    expect(find.text('frente').hitTestable(), findsOneWidget);
    expect(find.text('verso').hitTestable(), findsNothing);
    expect(tester.getSize(find.byType(FlipCard)).height, 80);
  });

  testWidgets('virar gira até o verso', (tester) async {
    await pump(tester, flipped: false);

    await pump(tester, flipped: true);
    expect(find.text('frente').hitTestable(), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('verso').hitTestable(), findsOneWidget);
    expect(find.text('frente').hitTestable(), findsNothing);
    expect(tester.getSize(find.byType(FlipCard)).height, 120);
  });
}
