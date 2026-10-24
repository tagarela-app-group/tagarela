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

  testWidgets('centerLast: último item no meio do espaço que sobra', (
    tester,
  ) async {
    await tester.pumpPage(
      const SheetPage(
        header: Text('Header'),
        centerLast: true,
        children: [Text('Topo'), Text('Vazio')],
      ),
    );

    final body = tester.getRect(find.byType(CustomScrollView));
    final top = tester.getRect(find.text('Topo'));
    final empty = tester.getRect(find.text('Vazio'));
    expect(top.top, lessThan(body.top + 50));
    expect(empty.center.dx, closeTo(body.center.dx, 1));
    expect(empty.top, greaterThan(body.top + body.height / 3));
  });

  testWidgets('centerLast com StateMessage: mensagem no meio, não no topo', (
    tester,
  ) async {
    await tester.pumpPage(
      const SheetPage(
        header: Text('Header'),
        centerLast: true,
        children: [
          StateMessage(
            icon: AppIcons.inbox,
            title: 'Vazio',
            message: 'Nada por aqui.',
          ),
        ],
      ),
    );

    final body = tester.getRect(find.byType(CustomScrollView));
    final message = tester.getRect(find.byType(StateMessage));
    expect(message.height, lessThan(body.height / 2));
    expect(message.center.dy, closeTo(body.center.dy, 1));
  });

  testWidgets('centerLast com onRefresh: puxar ainda atualiza', (tester) async {
    var refreshed = 0;
    await tester.pumpComponent(
      SheetPage(
        header: const Text('Header'),
        centerLast: true,
        onRefresh: () async => refreshed++,
        children: const [Text('Vazio')],
      ),
    );

    await tester.fling(find.text('Vazio'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(refreshed, 1);
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

  testWidgets('footer fica fixo embaixo, fora da rolagem', (tester) async {
    await tester.pumpPage(
      SheetPage(
        header: const Text('Header'),
        footer: const Text('Rodapé'),
        children: [
          for (var i = 0; i < 40; i++)
            SizedBox(height: 100, child: Text('Item $i')),
        ],
      ),
    );
    final before = tester.getTopLeft(find.text('Rodapé'));

    await tester.scrollUntilVisible(find.text('Item 39'), 500);

    expect(tester.getTopLeft(find.text('Rodapé')), before);
    expect(
      tester.getBottomLeft(find.byType(ListView)).dy,
      lessThanOrEqualTo(before.dy),
    );
  });
}
