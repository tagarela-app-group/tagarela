import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/auth/new_password_page.dart';
import 'package:tagarela/features/auth/reset_code_page.dart';
import 'package:tagarela/features/auth/widgets/code_step.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeAuthApi api;

  setUp(() => api = FakeAuthApi());

  Future<void> pumpResetCode(WidgetTester tester) => tester.pumpPage(
    const ResetCodePage(email: 'ana@example.com', sessionToken: 'session-1'),
    deps: fakeDependencies(auth: fakeAuthStore(api: api)),
    load: false,
  );

  testWidgets('código válido vai pra nova senha', (tester) async {
    await pumpResetCode(tester);

    await tester.enterText(find.byType(TextField), '482913');
    await tester.pumpAndSettle();

    expect(find.byType(NewPasswordPage), findsOneWidget);
    expect(api.last('GET /auth/password/reset').headers, {
      'X-Password-Reset-Key': '482913',
      'X-Session-Token': 'session-1',
    });
  });

  testWidgets('código inválido mostra erro', (tester) async {
    api.responses['GET /auth/password/reset'] = FakeAuthApi.errors({
      'key': 'Código inválido.',
    });
    await pumpResetCode(tester);

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();

    expect(find.text('Código inválido.'), findsOneWidget);
    expect(find.byType(NewPasswordPage), findsNothing);
  });

  testWidgets('reenviar pede código novo e passa a usar o token novo', (
    tester,
  ) async {
    api.responses['POST /auth/password/request'] = FakeAuthApi.pending(
      'password_reset_by_code',
      'session-2',
    );
    await pumpResetCode(tester);

    await tester.pump(CodeStep.resendAfter);
    await tester.tap(find.text('Reenviar código'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '111222');
    await tester.pump();

    expect(api.last('POST /auth/password/request').body, {
      'email': 'ana@example.com',
    });
    expect(
      api.last('GET /auth/password/reset').headers['X-Session-Token'],
      'session-2',
    );
  });
}
