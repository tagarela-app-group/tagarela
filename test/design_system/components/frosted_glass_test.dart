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

  testWidgets('passar o dedo desembaça e, passado do ponto, avisa uma vez', (
    tester,
  ) async {
    var wiped = 0;
    await tester.pumpComponent(
      Center(
        child: SizedBox(
          width: 320,
          child: FrostedGlass(
            frosted: true,
            onWiped: () => wiped++,
            overlay: const Text('convite'),
            actions: TextButton(onPressed: () {}, child: const Text('dica')),
            child: const SizedBox(height: 240, child: Text('segredo')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final box = tester.getRect(find.byType(FrostedGlass));

    Future<void> swipe(double y) => tester.timedDragFrom(
      Offset(box.left + 4, box.top + y),
      Offset(box.width - 8, 0),
      const Duration(milliseconds: 400),
    );

    await swipe(10);
    await tester.pumpAndSettle();

    expect(wiped, 0);
    final invite = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text('convite'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(invite.opacity, 0);
    expect(find.text('dica').hitTestable(), findsOneWidget);

    for (final y in [50.0, 90.0, 130.0, 170.0, 210.0, 235.0]) {
      await swipe(y);
    }
    await tester.pumpAndSettle();

    expect(wiped, 1);
  });

  testWidgets('sem onWiped o dedo não mexe no vidro', (tester) async {
    await tester.pumpComponent(
      const FrostedGlass(
        frosted: true,
        overlay: Text('convite'),
        child: SizedBox(height: 200, width: 300, child: Text('segredo')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.timedDrag(
      find.byType(FrostedGlass),
      const Offset(200, 0),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    final invite = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text('convite'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(invite.opacity, 1);
  });
}
