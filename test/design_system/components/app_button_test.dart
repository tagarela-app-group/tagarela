import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra rótulo e chama onPressed no toque', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      AppButton(label: 'Entrar', onPressed: () => taps++),
    );

    await tester.tap(find.text('Entrar'));
    expect(taps, 1);
  });

  testWidgets('onPressed nulo desabilita o botão', (tester) async {
    await tester.pumpComponent(
      const AppButton(label: 'Entrar', onPressed: null),
    );

    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.enabled, isFalse);
  });

  testWidgets('mostra leading antes do rótulo', (tester) async {
    await tester.pumpComponent(
      AppButton(
        label: 'Google',
        onPressed: () {},
        leading: const Icon(AppIcons.add),
      ),
    );

    expect(find.byIcon(AppIcons.add), findsOneWidget);
  });

  testWidgets('todas as variantes e tamanhos montam', (tester) async {
    for (final variant in AppButtonVariant.values) {
      for (final size in AppButtonSize.values) {
        await tester.pumpComponent(
          AppButton(
            label: 'Ok',
            onPressed: () {},
            variant: variant,
            size: size,
          ),
        );
        expect(tester.takeException(), isNull, reason: '$variant $size');
      }
    }
  });

  testWidgets('expand ocupa a largura toda', (tester) async {
    await tester.pumpComponent(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [AppButton(label: 'Ok', onPressed: () {}, expand: true)],
      ),
    );

    expect(tester.getSize(find.byType(TextButton)).width, 800);
  });
}
