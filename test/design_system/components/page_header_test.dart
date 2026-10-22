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

  testWidgets('subtítulo é opcional', (tester) async {
    await tester.pumpComponent(const PageHeader(title: 'Inbox'));

    expect(find.byType(Text), findsOneWidget);
  });
}
