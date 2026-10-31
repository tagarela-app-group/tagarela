import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('sem onTap não é tocável', (tester) async {
    await tester.pumpComponent(const AppCard(child: Text('Card')));

    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('com onTap chama no toque', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      AppCard(onTap: () => taps++, child: const Text('Card')),
    );

    await tester.tap(find.text('Card'));
    expect(taps, 1);
  });

  testWidgets('com onLongPress chama ao segurar', (tester) async {
    var presses = 0;
    await tester.pumpComponent(
      AppCard(onLongPress: () => presses++, child: const Text('Card')),
    );

    await tester.longPress(find.text('Card'));
    expect(presses, 1);
  });
}
