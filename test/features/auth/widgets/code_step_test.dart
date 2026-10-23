import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/widgets/code_step.dart';

import '../../../helpers/pump_app.dart';

void main() {
  late List<String> calls;
  late TextEditingController controller;

  setUp(() {
    calls = [];
    controller = TextEditingController();
  });

  Future<void> pumpStep(WidgetTester tester, {bool busy = false}) =>
      tester.pumpComponent(
        CodeStep(
          email: 'ana@example.com',
          controller: controller,
          busy: busy,
          onConfirm: () => calls.add('confirm'),
          onResend: () async => calls.add('resend'),
          onChangeEmail: () => calls.add('change'),
        ),
      );

  AppButton button(WidgetTester tester, String label) =>
      tester.widget<AppButton>(find.widgetWithText(AppButton, label));

  testWidgets('"Confirmar" só libera com o código completo', (tester) async {
    await pumpStep(tester);
    expect(button(tester, 'Confirmar').onPressed, isNull);

    controller.text = '48291';
    await tester.pump();
    expect(button(tester, 'Confirmar').onPressed, isNull);

    await tester.enterText(find.byType(TextField), '482913');
    await tester.pump();

    expect(calls, ['confirm']);
    expect(button(tester, 'Confirmar').onPressed, isNotNull);
  });

  testWidgets('ocupado não confirma', (tester) async {
    await pumpStep(tester, busy: true);

    await tester.enterText(find.byType(TextField), '482913');
    await tester.pump();

    expect(calls, isEmpty);
    expect(button(tester, 'Confirmar').onPressed, isNull);
  });

  testWidgets('contagem regressiva libera o reenvio e reinicia', (
    tester,
  ) async {
    await pumpStep(tester);
    expect(find.text('Não chegou? Reenviar em 1:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 18));
    expect(find.text('Não chegou? Reenviar em 0:42'), findsOneWidget);

    await tester.pump(const Duration(seconds: 42));
    await tester.tap(find.text('Reenviar código'));
    await tester.pump();

    expect(calls, ['resend']);
    expect(find.text('Não chegou? Reenviar em 1:00'), findsOneWidget);
  });

  testWidgets('"Trocar e-mail" avisa', (tester) async {
    await pumpStep(tester);

    await tester.tap(find.text('Trocar e-mail'));

    expect(calls, ['change']);
  });
}
