import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('tom primary usa a cor de ação', (tester) async {
    await tester.pumpComponent(
      const AppBadge(label: '3', tone: AppBadgeTone.primary),
    );

    final box = tester.widget<Container>(find.byType(Container));
    final text = tester.widget<Text>(find.text('3'));
    expect((box.decoration! as BoxDecoration).color, AppColors.light.primary);
    expect(text.style?.color, AppColors.light.onPrimary);
  });

  testWidgets('tom alert usa a cor de alerta', (tester) async {
    await tester.pumpComponent(
      const AppBadge(label: '1', tone: AppBadgeTone.alert),
    );

    final box = tester.widget<Container>(find.byType(Container));
    expect((box.decoration! as BoxDecoration).color, AppColors.light.alert);
  });
}
