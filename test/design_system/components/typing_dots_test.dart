import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('reduzir movimento deixa parado', (tester) async {
    await tester.pumpComponent(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: TypingDots(color: Colors.white),
      ),
    );

    await tester.pump(AppMotion.typing);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
