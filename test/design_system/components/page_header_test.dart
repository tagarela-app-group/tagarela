import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra título, subtítulo, leading e trailing', (tester) async {
    await tester.pumpComponent(
      const PageHeader(
        title: 'Inbox',
        subtitle: '4 termos',
        leading: Icon(AppIcons.inbox),
        trailing: Icon(AppIcons.more),
      ),
    );

    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('4 termos'), findsOneWidget);
    expect(find.byIcon(AppIcons.inbox), findsOneWidget);
    expect(find.byIcon(AppIcons.more), findsOneWidget);
  });

  testWidgets('centered: leading em cima e textos no meio', (tester) async {
    await tester.pumpComponent(
      const PageHeader(
        title: 'Ana Souza',
        subtitle: 'ana@example.com',
        leading: Icon(AppIcons.profile),
        centered: true,
      ),
    );

    final header = tester.getRect(find.byType(PageHeader));
    final icon = tester.getRect(find.byIcon(AppIcons.profile));
    final title = tester.getRect(find.text('Ana Souza'));
    expect(icon.bottom, lessThanOrEqualTo(title.top));
    expect(icon.center.dx, closeTo(header.center.dx, 1));
    expect(
      tester.widget<Text>(find.text('ana@example.com')).textAlign,
      TextAlign.center,
    );
  });

  testWidgets('subtítulo é opcional', (tester) async {
    await tester.pumpComponent(const PageHeader(title: 'Inbox'));

    expect(find.byType(Text), findsOneWidget);
  });
}
