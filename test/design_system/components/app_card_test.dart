import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

T _inCard<T extends Widget>(WidgetTester tester) => tester.widget<T>(
  find.descendant(of: find.byType(AppCard), matching: find.byType(T)).first,
);

void main() {
  testWidgets('sem onTap não é tocável', (tester) async {
    await tester.pumpComponent(const AppCard(child: Text('Card')));

    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('com onTap chama no toque', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      AppCard(onTap: () => taps++, child: const Text('Card')),
    );

    await tester.tap(find.text('Card'));
    expect(taps, 1);
  });

  testWidgets('com onLongPress chama ao segurar', (tester) async {
    var presses = 0;
    await tester.pumpComponent(
      AppCard(onLongPress: () => presses++, child: const Text('Card')),
    );

    await tester.longPress(find.text('Card'));
    expect(presses, 1);
  });

  testWidgets('cor própria remove a sombra', (tester) async {
    await tester.pumpComponent(
      const AppCard(color: AppPalette.mango, child: Text('Card')),
    );

    final box = _inCard<DecoratedBox>(tester);
    expect((box.decoration as BoxDecoration).boxShadow, isNull);
  });

  testWidgets('muted: sem fundo, sem sombra, com borda', (tester) async {
    await tester.pumpComponent(const AppCard(muted: true, child: Text('Card')));

    final box = _inCard<DecoratedBox>(tester);
    final material = _inCard<Material>(tester);
    final shape = material.shape! as RoundedRectangleBorder;
    expect((box.decoration as BoxDecoration).boxShadow, isNull);
    expect(material.color, Colors.transparent);
    expect(shape.side.color, AppColors.light.line);
  });

  testWidgets('selected: borda primary de 2, sem sombra', (tester) async {
    await tester.pumpComponent(
      const AppCard(selected: true, child: Text('Card')),
    );

    final box = _inCard<DecoratedBox>(tester);
    final material = _inCard<Material>(tester);
    final shape = material.shape! as RoundedRectangleBorder;
    expect((box.decoration as BoxDecoration).boxShadow, isNull);
    expect(shape.side.color, AppColors.light.primary);
    expect(shape.side.width, 2);
  });
}
