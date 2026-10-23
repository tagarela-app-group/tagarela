import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra header e itens do body', (tester) async {
    await tester.pumpPage(
      const SheetPage(
        header: Text('Header'),
        children: [Text('Item 1'), Text('Item 2')],
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
  });

  testWidgets('body rola quando o conteúdo passa da tela', (tester) async {
    await tester.pumpPage(
      SheetPage(
        header: const Text('Header'),
        children: [
          for (var i = 0; i < 40; i++)
            SizedBox(height: 100, child: Text('Item $i')),
        ],
      ),
    );

    expect(find.text('Item 39'), findsNothing);
    await tester.scrollUntilVisible(find.text('Item 39'), 500);
    expect(find.text('Item 39'), findsOneWidget);
    expect(find.text('Header'), findsOneWidget);
  });

  testWidgets('onRefresh: puxar a lista chama a função', (tester) async {
    var refreshed = 0;
    await tester.pumpComponent(
      SheetPage(
        header: const Text('Header'),
        onRefresh: () async => refreshed++,
        children: const [Text('Item')],
      ),
    );

    await tester.fling(find.text('Item'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(refreshed, 1);
  });

  testWidgets('sem onRefresh: sem RefreshIndicator', (tester) async {
    await tester.pumpComponent(
      const SheetPage(header: Text('Header'), children: [Text('Item')]),
    );

    expect(find.byType(RefreshIndicator), findsNothing);
  });
}
