import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

const _color = Color(0xFF00FF00);

Finder get _paint => find.descendant(
  of: find.byType(SpeechBubbleIcon),
  matching: find.byType(CustomPaint),
);

void main() {
  testWidgets('desenha o balão no tamanho e cor pedidos', (tester) async {
    await tester.pumpComponent(
      const Center(child: SpeechBubbleIcon(size: 150, color: _color)),
    );

    expect(tester.getSize(find.byType(SpeechBubbleIcon)), const Size(150, 150));
    expect(tester.renderObject(_paint), paints..path(color: _color));
  });

  testWidgets('sem tamanho e cor, segue o IconTheme', (tester) async {
    await tester.pumpComponent(
      const Center(
        child: IconTheme(
          data: IconThemeData(size: 40, color: _color),
          child: SpeechBubbleIcon(),
        ),
      ),
    );

    expect(tester.getSize(find.byType(SpeechBubbleIcon)), const Size(40, 40));
    expect(tester.renderObject(_paint), paints..path(color: _color));
  });
}
