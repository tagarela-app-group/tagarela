import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

const _items = [
  AppTabItem(icon: AppIcons.home, label: 'Início'),
  AppTabItem(icon: AppIcons.inbox, label: 'Inbox', badge: 3),
];

void main() {
  testWidgets('toque devolve o índice da aba', (tester) async {
    int? tapped;
    await tester.pumpComponent(
      AppTabBar(items: _items, currentIndex: 0, onTap: (i) => tapped = i),
    );

    await tester.tap(find.text('Inbox'));
    expect(tapped, 1);
  });

  testWidgets('badge só aparece com valor maior que zero', (tester) async {
    await tester.pumpComponent(
      AppTabBar(items: _items, currentIndex: 0, onTap: (_) {}),
    );

    final visible = tester
        .widgetList<Badge>(find.byType(Badge))
        .map((b) => b.isLabelVisible);
    expect(visible, [false, true]);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('ícone fica centrado na pílula, com ou sem badge', (
    tester,
  ) async {
    await tester.pumpComponent(
      AppTabBar(items: _items, currentIndex: 0, onTap: (_) {}),
    );

    for (final icon in [AppIcons.home, AppIcons.inbox]) {
      final pill = find.ancestor(
        of: find.byIcon(icon),
        matching: find.byType(AnimatedContainer),
      );
      expect(tester.getCenter(find.byIcon(icon)), tester.getCenter(pill));
    }
  });

  testWidgets('marca a aba atual na acessibilidade', (tester) async {
    await tester.pumpComponent(
      AppTabBar(items: _items, currentIndex: 1, onTap: (_) {}),
    );

    expect(
      tester.getSemantics(find.text('Início')),
      isSemantics(isSelected: false),
    );
    expect(
      tester.getSemantics(find.text('Inbox')),
      isSemantics(isSelected: true),
    );
  });

  testWidgets('centerGap abre espaço no meio', (tester) async {
    await tester.pumpComponent(
      AppTabBar(items: _items, currentIndex: 0, onTap: (_) {}, centerGap: 72),
    );

    final row = tester.widget<Row>(
      find.descendant(of: find.byType(AppTabBar), matching: find.byType(Row)),
    );
    expect(row.children, hasLength(3));
    expect((row.children[1] as SizedBox).width, 72);
  });
}
