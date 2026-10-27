import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('bandeira de trás pequena no alto e a da frente maior com anel', (
    tester,
  ) async {
    await tester.pumpComponent(
      const Center(
        child: FlagPair(back: 'BR', front: 'US'),
      ),
    );

    expect(tester.getSize(find.byType(FlagPair)), const Size(56, 48));
    final flags = tester.widgetList<FlagBadge>(find.byType(FlagBadge)).toList();
    expect([for (final f in flags) f.country], ['BR', 'US']);
    expect(flags.first.size, 30);
    expect(flags.first.ring, isNull);
    expect(flags.last.size, closeTo(38.4, 0.001));
    expect(flags.last.ring, AppColors.light.surface);
    final pair = tester.getRect(find.byType(FlagPair));
    expect(tester.getTopLeft(find.byType(FlagBadge).first), pair.topLeft);
    expect(
      tester.getBottomRight(find.byType(FlagBadge).last),
      pair.bottomRight,
    );
  });
}
