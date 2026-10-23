import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Color background(WidgetTester tester) {
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(TermChip),
        matching: find.byType(Container),
      ),
    );
    return (box.decoration! as BoxDecoration).color!;
  }

  testWidgets('sem onRemove: só o termo, sem botão', (tester) async {
    await tester.pumpComponent(const TermChip(label: 'mind the gap'));

    expect(find.text('mind the gap'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
    expect(tester.getSize(find.byType(TermChip)).height, 30);
    expect(background(tester), AppColors.light.primarySoft);
  });

  testWidgets('com onRemove: X chama a função', (tester) async {
    var removed = 0;
    await tester.pumpComponent(
      TermChip(label: 'mind', onRemove: () => removed++),
    );

    await tester.tap(find.byTooltip('Remover mind'));

    expect(removed, 1);
    expect(tester.getSize(find.byType(TermChip)).height, 40);
  });

  testWidgets('muted: fundo neutro', (tester) async {
    await tester.pumpComponent(const TermChip(label: 'mind', muted: true));

    expect(background(tester), AppColors.light.surfaceAlt);
  });
}
