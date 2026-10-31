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

    expect(find.text('3'), findsOneWidget);
    expect(find.text('0'), findsNothing);
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

  testWidgets('aba desligada não responde e avisa a acessibilidade', (
    tester,
  ) async {
    int? tapped;
    await tester.pumpComponent(
      AppTabBar(
        items: const [
          AppTabItem(icon: AppIcons.home, label: 'Início'),
          AppTabItem(
            icon: AppIcons.community,
            label: 'Comunidades',
            enabled: false,
          ),
        ],
        currentIndex: 0,
        onTap: (i) => tapped = i,
      ),
    );

    await tester.tap(find.text('Comunidades'));

    expect(tapped, isNull);
    expect(
      tester.getSemantics(find.text('Comunidades')),
      isSemantics(hasEnabledState: true, isEnabled: false),
    );
  });

  testWidgets('rótulo longo com fonte grande encolhe em uma linha', (
    tester,
  ) async {
    await tester.pumpComponent(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: SizedBox(
          width: 320,
          child: AppTabBar(
            items: const [
              AppTabItem(icon: AppIcons.home, label: 'Início'),
              AppTabItem(icon: AppIcons.vocabulary, label: 'Vocabulário'),
              AppTabItem(icon: AppIcons.inbox, label: 'Inbox'),
              AppTabItem(icon: AppIcons.community, label: 'Comunidades'),
            ],
            currentIndex: 0,
            onTap: (_) {},
            centerGap: 72,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    for (final label in ['Vocabulário', 'Comunidades']) {
      final tab = find.ancestor(
        of: find.text(label),
        matching: find.byType(Expanded),
      );
      final rect = tester.getRect(find.text(label));
      expect(rect.width, lessThanOrEqualTo(tester.getSize(tab).width));
      expect(rect.height, lessThan(AppTabBar.height));
    }
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
