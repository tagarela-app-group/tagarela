import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('superfície arredondada em cima, com a folga do sistema', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(bottom: 30);
    addTearDown(tester.view.resetPadding);
    await tester.pumpComponent(
      const Align(
        alignment: Alignment.bottomCenter,
        child: BottomPanel(child: SizedBox(height: 40, width: 100)),
      ),
    );

    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(BottomPanel),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, AppColors.light.surface);
    expect(
      decoration.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    );
    final padding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(BottomPanel),
        matching: find.byType(Padding),
      ),
    );
    expect(padding.padding.vertical, greaterThan(AppSpacing.s3 * 2));
  });
}
