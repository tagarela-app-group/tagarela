import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool frosted}) =>
      tester.pumpComponent(
        FrostedGlass(
          frosted: frosted,
          overlay: TextButton(onPressed: () {}, child: const Text('revelar')),
          child: const SizedBox(height: 120, child: Text('segredo')),
        ),
      );

  testWidgets('embaçado: esconde o conteúdo da leitura e mostra o convite', (
    tester,
  ) async {
    await pump(tester, frosted: true);
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.bySemanticsLabel('segredo'), findsNothing);
    expect(find.bySemanticsLabel('revelar'), findsOneWidget);
  });

  testWidgets('limpo: some o vidro e o convite, o conteúdo volta', (
    tester,
  ) async {
    await pump(tester, frosted: true);
    await pump(tester, frosted: false);
    await tester.pumpAndSettle();

    final opacities = tester
        .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .map((o) => o.opacity);
    expect(opacities, everyElement(0));
    expect(find.bySemanticsLabel('segredo'), findsOneWidget);
    expect(find.text('revelar').hitTestable(), findsNothing);
  });

  testWidgets(
    'convite maior que o conteúdo estica o vidro só enquanto embaça',
    (tester) async {
      Future<void> pumpTall({required bool frosted}) => tester.pumpComponent(
        FrostedGlass(
          frosted: frosted,
          overlay: const SizedBox(height: 200, child: Text('revelar')),
          child: const SizedBox(height: 60, child: Text('segredo')),
        ),
      );

      await pumpTall(frosted: true);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(FrostedGlass)).height, 240);

      await pumpTall(frosted: false);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(FrostedGlass)).height, 60);
    },
  );
}
