import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

const _color = Color(0xFF00FF00);

void main() {
  testWidgets('desenha cada traço no tamanho e cor pedidos', (tester) async {
    for (final glyph in DrawnGlyph.values) {
      await tester.pumpComponent(
        Center(child: DrawnIcon(glyph, size: 48, color: _color)),
      );

      expect(tester.getSize(find.byType(DrawnIcon)), const Size(48, 48));
      expect(
        tester.renderObject(
          find.descendant(
            of: find.byType(DrawnIcon),
            matching: find.byType(CustomPaint),
          ),
        ),
        paints..path(color: _color, style: PaintingStyle.stroke),
      );
    }
  });

  testWidgets('sem tamanho e cor, segue o IconTheme', (tester) async {
    await tester.pumpComponent(
      const Center(
        child: IconTheme(
          data: IconThemeData(size: 20, color: _color),
          child: DrawnIcon(DrawnGlyph.turtle),
        ),
      ),
    );

    expect(tester.getSize(find.byType(DrawnIcon)), const Size(20, 20));
  });
}
