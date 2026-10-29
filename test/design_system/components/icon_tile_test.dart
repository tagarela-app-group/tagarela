import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
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
}
