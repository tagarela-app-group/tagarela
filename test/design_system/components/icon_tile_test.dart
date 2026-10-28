import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Color? background(WidgetTester tester) =>
      (tester.widget<Container>(find.byType(Container)).decoration!
              as BoxDecoration)
          .color;

  testWidgets('com acento usa a cor do acento', (tester) async {
    await tester.pumpComponent(
      const IconTile(icon: AppIcons.text, accent: AppAccent.violet),
    );

    expect(background(tester), AppColors.light.accent(AppAccent.violet).soft);
  });

  testWidgets('glyph no lugar do ícone, com tamanho e cor do acento', (
    tester,
  ) async {
    await tester.pumpComponent(
      const IconTile(
        glyph: DrawnIcon(DrawnGlyph.bubble),
        accent: AppAccent.violet,
        size: 64,
      ),
    );

    final bubble = drawnIcon(DrawnGlyph.bubble);
    expect(bubble, findsOneWidget);
    expect(tester.getSize(bubble), const Size.square(32));
    expect(
      IconTheme.of(tester.element(bubble)).color,
      AppColors.light.accent(AppAccent.violet).fg,
    );
  });

  testWidgets('sem acento fica neutro', (tester) async {
    await tester.pumpComponent(const IconTile(icon: AppIcons.text));

    expect(background(tester), AppColors.light.surfaceAlt);
    expect(
      tester.widget<Icon>(find.byType(Icon)).color,
      AppColors.light.inkSoft,
    );
  });
}
