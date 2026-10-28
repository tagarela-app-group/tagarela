import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('título em negrito e texto de apoio suave', (tester) async {
    await tester.pumpComponent(
      const TitledText(title: 'Título', text: 'Apoio'),
    );

    final title = tester.widget<Text>(find.text('Título'));
    final text = tester.widget<Text>(find.text('Apoio'));
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(text.style?.color, AppColors.light.inkSoft);
  });

  testWidgets('sem texto, só o título', (tester) async {
    await tester.pumpComponent(const TitledText(title: 'Título'));

    expect(find.byType(Text), findsOneWidget);
  });
}
