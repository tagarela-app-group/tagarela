import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('tem tooltip e chama onPressed', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      AppIconButton(
        icon: AppIcons.back,
        tooltip: 'Voltar',
        onPressed: () => taps++,
      ),
    );

    expect(find.byTooltip('Voltar'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    expect(taps, 1);
  });

  testWidgets('tamanho define o botão', (tester) async {
    await tester.pumpComponent(
      AppIconButton(
        icon: AppIcons.back,
        tooltip: 'Voltar',
        onPressed: () {},
        size: 40,
      ),
    );

    expect(tester.getSize(find.byType(IconButton)), const Size.square(40));
  });

  testWidgets('todas as variantes montam', (tester) async {
    for (final variant in AppIconButtonVariant.values) {
      await tester.pumpComponent(
        AppIconButton(
          icon: AppIcons.back,
          tooltip: 'Voltar',
          onPressed: () {},
          variant: variant,
        ),
      );
      expect(tester.takeException(), isNull, reason: '$variant');
    }
  });
}
