import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/auth/widgets/social_buttons.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('Android: só Google', (tester) async {
    var google = 0;
    await tester.pumpComponent(
      SocialButtons(onGoogle: () => google++, onApple: () {}),
    );

    await tester.tap(find.text('Continuar com Google'));

    expect(google, 1);
    expect(find.text('Continuar com a Apple'), findsNothing);
  });

  testWidgets('iOS: Google e Apple', (tester) async {
    var apple = 0;
    await tester.pumpComponent(
      SocialButtons(onGoogle: () {}, onApple: () => apple++),
    );

    await tester.tap(find.text('Continuar com a Apple'));

    expect(apple, 1);
    expect(find.text('Continuar com Google'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
