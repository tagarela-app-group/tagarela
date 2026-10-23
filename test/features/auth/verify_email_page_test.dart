import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/features/auth/verify_email_page.dart';
import 'package:tagarela/features/auth/widgets/code_step.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeAuthApi api;

  setUp(() => api = FakeAuthApi());

  Future<void> pumpVerify(WidgetTester tester) => tester.pumpPage(
    const VerifyEmailPage(email: 'ana@example.com', sessionToken: 'session-1'),
    auth: fakeAuthStore(api: api),
    load: false,
  );

  testWidgets('6 dígitos confirmam e abrem o app', (tester) async {
    await pumpVerify(tester);

    await tester.enterText(find.byType(TextField), '482913');
    await tester.pumpAndSettle();

    expect(find.byType(HomeShell), findsOneWidget);
    final request = api.last('POST /auth/email/verify');
    expect(request.body, {'key': '482913'});
    expect(request.headers['X-Session-Token'], 'session-1');
  });

  testWidgets('código errado mostra erro e fica na tela', (tester) async {
    api.responses['POST /auth/email/verify'] = FakeAuthApi.errors({
      'key': 'Código incorreto.',
    });
    await pumpVerify(tester);

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();

    expect(find.text('Código incorreto.'), findsOneWidget);
    expect(find.byType(VerifyEmailPage), findsOneWidget);
  });

  testWidgets('reenviar libera depois da espera e manda o token', (
    tester,
  ) async {
    await pumpVerify(tester);
    expect(find.text('Não chegou? Reenviar em 1:00'), findsOneWidget);

    await tester.pump(CodeStep.resendAfter);
    await tester.tap(find.text('Reenviar código'));
    await tester.pump();

    expect(
      api.last('POST /auth/email/verify/resend').headers['X-Session-Token'],
      'session-1',
    );
    expect(find.text('Não chegou? Reenviar em 1:00'), findsOneWidget);
  });
}
