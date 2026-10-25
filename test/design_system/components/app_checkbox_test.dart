import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('marcado mostra o check; desmarcado, só a borda', (tester) async {
    await tester.pumpComponent(const AppCheckbox(checked: true));
    expect(find.byIcon(AppIcons.check), findsOneWidget);

    await tester.pumpComponent(const AppCheckbox(checked: false));
    await tester.pumpAndSettle();
    expect(find.byIcon(AppIcons.check), findsNothing);
  });

  testWidgets('redondo vira círculo', (tester) async {
    await tester.pumpComponent(const AppCheckbox(checked: true, round: true));

    final box = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(
      (box.decoration! as BoxDecoration).borderRadius,
      BorderRadius.circular(AppCheckbox.size / 2),
    );
  });
}
