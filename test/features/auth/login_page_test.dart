import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra campos de e-mail e senha', (tester) async {
    await tester.pumpPage(const LoginPage(), load: false);

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.byTooltip('Mostrar senha'), findsOneWidget);
  });

  for (final label in ['Entrar', 'Continuar com Google']) {
    testWidgets('"$label" carrega dados e troca login pelo app', (
      tester,
    ) async {
      final scope = await tester.pumpPage(const LoginPage(), load: false);

      await tester.tap(find.widgetWithText(AppButton, label));
      await tester.pumpAndSettle();

      expect(find.byType(HomeShell), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      expect(navigator.canPop(), isFalse);
      expect(scope.user.data, isNotNull);
    });
  }
}
