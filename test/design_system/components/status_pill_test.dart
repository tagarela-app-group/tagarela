import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('tom alert usa o coral', (tester) async {
    await tester.pumpComponent(
      const StatusPill(label: 'Erro', tone: StatusTone.alert),
    );

    final coral = AppColors.light.accent(AppAccent.coral);
    final box = tester.widget<Container>(find.byType(Container));
    final text = tester.widget<Text>(find.text('Erro'));
    expect((box.decoration! as BoxDecoration).color, coral.soft);
    expect(text.style?.color, coral.fg);
  });
}
