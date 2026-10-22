import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

const _fill = Color(0xFF00FF00);

List<Color?> _dotColors(WidgetTester tester) => tester
    .widgetList<Container>(
      find.descendant(
        of: find.byType(LevelDots),
        matching: find.byType(Container),
      ),
    )
    .map((c) => (c.decoration! as BoxDecoration).color)
    .toList();

void main() {
  testWidgets('pinta `level` traços de `max`', (tester) async {
    await tester.pumpComponent(const LevelDots(level: 3, color: _fill));

    final colors = _dotColors(tester);
    expect(colors, hasLength(5));
    expect(colors.where((c) => c == _fill), hasLength(3));
  });

  testWidgets('respeita max customizado', (tester) async {
    await tester.pumpComponent(const LevelDots(level: 0, color: _fill, max: 3));

    final colors = _dotColors(tester);
    expect(colors, hasLength(3));
    expect(colors, isNot(contains(_fill)));
  });

  testWidgets('rótulo de acessibilidade', (tester) async {
    await tester.pumpComponent(const LevelDots(level: 2, color: _fill));

    expect(find.bySemanticsLabel('Nível 2 de 5'), findsOneWidget);
  });
}
