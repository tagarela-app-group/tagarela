import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('número fica no centro do badge mesmo com fonte grande', (
    tester,
  ) async {
    await tester.pumpComponent(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Center(
          child: AppBadge(label: '3', tone: AppBadgeTone.alert),
        ),
      ),
    );

    final badge = tester.getRect(find.byType(AppBadge));
    final number = tester.getRect(find.text('3'));

    expect(number.center.dy, closeTo(badge.center.dy, 0.5));
    expect(badge.contains(number.topLeft), isTrue);
    expect(badge.contains(number.bottomRight), isTrue);
  });
}
