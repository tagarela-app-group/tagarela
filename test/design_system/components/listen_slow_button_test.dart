import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('tartaruga parado, parar tocando; toque chama a ação', (
    tester,
  ) async {
    var taps = 0;
    for (final playing in [false, true]) {
      await tester.pumpComponent(
        ListenSlowButton(playing: playing, onPressed: () => taps++),
      );

      expect(
        drawnIcon(DrawnGlyph.turtle),
        playing ? findsNothing : findsOneWidget,
      );
      expect(
        find.byIcon(AppIcons.stop),
        playing ? findsOneWidget : findsNothing,
      );
      await tester.tap(find.text('Devagar'));
    }

    expect(taps, 2);
  });
}
