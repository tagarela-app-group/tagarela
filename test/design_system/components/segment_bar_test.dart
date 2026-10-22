import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

const _a = Color(0xFFFF0000);
const _b = Color(0xFF0000FF);

double _widthFactor(WidgetTester tester) => tester
    .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
    .widthFactor!;

void main() {
  testWidgets('sem total ocupa a barra toda', (tester) async {
    await tester.pumpComponent(
      const SegmentBar(segments: [Segment(2, _a), Segment(3, _b)]),
    );

    expect(_widthFactor(tester), 1);
  });

  testWidgets('com total vira progresso', (tester) async {
    await tester.pumpComponent(
      const SegmentBar(segments: [Segment(1, _a), Segment(2, _b)], total: 12),
    );

    expect(_widthFactor(tester), 0.25);
  });

  testWidgets('progresso limitado a 100%', (tester) async {
    await tester.pumpComponent(
      const SegmentBar(segments: [Segment(20, _a)], total: 10),
    );

    expect(_widthFactor(tester), 1);
  });

  testWidgets('total zero não divide por zero', (tester) async {
    await tester.pumpComponent(
      const SegmentBar(segments: [Segment(0, _a)], total: 0),
    );

    expect(_widthFactor(tester), 1);
  });

  testWidgets('segmento com valor zero não aparece', (tester) async {
    await tester.pumpComponent(
      const SegmentBar(segments: [Segment(0, _a), Segment(3, _b)]),
    );

    final parts = tester.widgetList<Expanded>(
      find.descendant(
        of: find.byType(SegmentBar),
        matching: find.byType(Expanded),
      ),
    );
    expect(parts, hasLength(1));
  });

  testWidgets('rótulo de acessibilidade', (tester) async {
    await tester.pumpComponent(
      const SegmentBar(
        segments: [Segment(1, _a)],
        semanticLabel: '1 aprendendo',
      ),
    );

    expect(find.bySemanticsLabel('1 aprendendo'), findsOneWidget);
  });
}
