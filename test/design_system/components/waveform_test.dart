import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

const _played = Color(0xFF00FF00);
const _rest = Color(0xFF0000FF);

void main() {
  Future<void> pump(WidgetTester tester, double progress) =>
      tester.pumpComponent(
        Center(
          child: SizedBox(
            width: 3 * (Waveform.barWidth + Waveform.gap) - Waveform.gap,
            child: Waveform(progress: progress, color: _played, track: _rest),
          ),
        ),
      );

  RenderObject paint(WidgetTester tester) => tester.renderObject(
    find.descendant(
      of: find.byType(Waveform),
      matching: find.byType(CustomPaint),
    ),
  );

  testWidgets('enche as barras até onde tocou', (tester) async {
    await pump(tester, 0.4);

    expect(
      paint(tester),
      paints
        ..rrect(color: _played)
        ..rrect(color: _rest)
        ..rrect(color: _rest),
    );
  });

  testWidgets('parado, tudo na cor do trilho e fora da leitura', (
    tester,
  ) async {
    await pump(tester, 0);

    expect(
      paint(tester),
      paints
        ..rrect(color: _rest)
        ..rrect(color: _rest)
        ..rrect(color: _rest),
    );
    expect(tester.getSize(find.byType(Waveform)).height, 30);
  });
}
