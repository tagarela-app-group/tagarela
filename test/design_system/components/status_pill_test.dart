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

  test('cada tom tem fundo e texto do papel dele', () {
    const c = AppColors.light;

    expect(StatusTone.learning.colors(c), (c.learningSoft, c.learningText));
    expect(StatusTone.mastered.colors(c), (c.masteredSoft, c.masteredText));
    expect(StatusTone.primary.colors(c), (c.primarySoft, c.primaryText));
    expect(StatusTone.neutral.colors(c), (c.surfaceAlt, c.inkSoft));
  });
}
