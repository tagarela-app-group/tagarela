import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> show(WidgetTester tester, {bool aboveTabBar = false}) async {
    await tester.pumpComponent(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => AppToast.show(
            context,
            title: 'Grupo criado',
            message: 'Música está no topo da lista.',
            actionLabel: 'Abrir',
            onAction: () {},
            aboveTabBar: aboveTabBar,
          ),
          child: const Text('mostrar'),
        ),
      ),
    );
    await tester.tap(find.text('mostrar'));
    await tester.pump();
  }

  testWidgets('título, texto e ação', (tester) async {
    await show(tester);

    expect(find.text('Grupo criado'), findsOneWidget);
    expect(find.text('Música está no topo da lista.'), findsOneWidget);
    expect(find.text('Abrir'), findsOneWidget);
    expect(find.byIcon(AppIcons.check), findsOneWidget);
  });

  testWidgets('acima da tab bar e do botão + quando pedido', (tester) async {
    await show(tester, aboveTabBar: true);

    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(
      (bar.margin! as EdgeInsets).bottom,
      AppTabBar.height + ArcMenu.overhang + AppSpacing.s4,
    );
  });

  testWidgets('some sozinho mesmo com ação', (tester) async {
    await show(tester);
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Grupo criado'), findsNothing);
  });
}
