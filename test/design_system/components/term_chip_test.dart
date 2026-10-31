import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('sem onRemove: só o termo, sem botão', (tester) async {
    await tester.pumpComponent(const TermChip(label: 'mind the gap'));

    expect(find.text('mind the gap'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('com onRemove: X chama a função', (tester) async {
    var removed = 0;
    await tester.pumpComponent(
      TermChip(label: 'mind', onRemove: () => removed++),
    );

    await tester.tap(find.byTooltip('Remover mind'));

    expect(removed, 1);
  });
}
