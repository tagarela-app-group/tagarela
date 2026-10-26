import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Finder visible(String text) => find.descendant(
    of: find.byType(AnimatedSwitcher),
    matching: find.text(text),
  );

  testWidgets('mostra o texto da vez e troca rolando', (tester) async {
    Widget rolling(int index) => Center(
      child: RollingText(texts: const ['um', 'dois longo'], index: index),
    );
    await tester.pumpComponent(rolling(0));

    expect(visible('um'), findsOneWidget);
    final size = tester.getSize(find.byType(RollingText));

    await tester.pumpComponent(rolling(1));
    await tester.pumpAndSettle();

    expect(visible('dois longo'), findsOneWidget);
    expect(visible('um'), findsNothing);
    expect(tester.getSize(find.byType(RollingText)), size);
  });

  testWidgets('volta pro primeiro depois do último', (tester) async {
    await tester.pumpComponent(
      const RollingText(texts: ['um', 'dois'], index: 2),
    );

    expect(visible('um'), findsOneWidget);
  });
}
