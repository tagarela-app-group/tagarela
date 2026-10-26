import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

const _color = Color(0xFF00FF00);
const _ring = Color(0xFF0000FF);

BoxDecoration _decoration(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration!
        as BoxDecoration;

void main() {
  testWidgets('balão com a ponta embaixo à esquerda', (tester) async {
    await tester.pumpComponent(
      const SpeechBalloon(color: _color, child: Text('oi')),
    );

    final decoration = _decoration(tester);
    expect(find.text('oi'), findsOneWidget);
    expect(decoration.color, _color);
    expect(decoration.borderRadius, AppRadius.bubble(AppRadius.lg));
    expect(decoration.border!.top.color, Colors.transparent);
  });

  testWidgets('espelhado põe a ponta à direita e o anel acende', (
    tester,
  ) async {
    await tester.pumpComponent(
      const SpeechBalloon(
        color: _color,
        mirrored: true,
        radius: 20,
        ring: _ring,
        child: Text('oi'),
      ),
    );
    await tester.pumpAndSettle();

    final decoration = _decoration(tester);
    expect(decoration.borderRadius, AppRadius.bubble(20, mirrored: true));
    expect(decoration.border!.top.color, _ring);
  });
}
