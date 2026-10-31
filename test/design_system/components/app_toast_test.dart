import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> show(
    WidgetTester tester, {
    bool aboveTabBar = false,
    String? actionLabel = 'Abrir',
    Duration duration = AppMotion.toast,
  }) async {
    await tester.pumpComponent(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => AppToast.show(
            context,
            title: 'Grupo criado',
            message: 'Música está no topo da lista.',
            actionLabel: actionLabel,
            onAction: () {},
            aboveTabBar: aboveTabBar,
            duration: duration,
          ),
          child: const Text('mostrar'),
        ),
      ),
    );
    await tester.tap(find.text('mostrar'));
    await tester.pump();
  }

  testWidgets('aviso novo toma o lugar do anterior, sem fila', (tester) async {
    await tester.pumpComponent(
      Builder(
        builder: (context) => Column(
          children: [
            TextButton(
              onPressed: () => AppToast.notice(context, 'primeiro'),
              child: const Text('a'),
            ),
            TextButton(
              onPressed: () => AppToast.notice(context, 'segundo'),
              child: const Text('b'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.text('b'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('primeiro'), findsNothing);
    expect(find.text('segundo'), findsOneWidget);
  });

  testWidgets('acima da tab bar e do botão + quando pedido', (tester) async {
    await show(tester, aboveTabBar: true);

    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(
      (bar.margin! as EdgeInsets).bottom,
      AppTabBar.height + ArcMenu.overhang + AppSpacing.s4,
    );
  });

  double ring(WidgetTester tester) => tester
      .widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator))
      .value!;

  testWidgets('anel esvazia e o toast sai no fim, mesmo com ação', (
    tester,
  ) async {
    await show(tester);

    expect(ring(tester), 1);

    await tester.pump(AppMotion.toast ~/ 2);
    expect(ring(tester), closeTo(0.5, 0.01));
    expect(find.text('Grupo criado'), findsOneWidget);

    await tester.pump(AppMotion.toast ~/ 2 - const Duration(milliseconds: 1));
    expect(find.text('Grupo criado'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Grupo criado'), findsNothing);
  });

  testWidgets('tempo na tela configurável', (tester) async {
    await show(tester, duration: const Duration(seconds: 2));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Grupo criado'), findsNothing);
  });
}
