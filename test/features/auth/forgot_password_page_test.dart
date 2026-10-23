import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/forgot_password_page.dart';
import 'package:tagarela/features/auth/reset_code_page.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeAuthApi api;

  setUp(() => api = FakeAuthApi());

  Future<void> pumpForgot(WidgetTester tester, {String email = ''}) =>
      tester.pumpPage(
        ForgotPasswordPage(email: email),
        auth: fakeAuthStore(api: api),
        load: false,
      );

  testWidgets('manda o e-mail preenchido e vai pro código', (tester) async {
    await pumpForgot(tester, email: 'ana@example.com');

    await tester.tap(find.widgetWithText(AppButton, 'Enviar código'));
    await tester.pumpAndSettle();

    expect(find.byType(ResetCodePage), findsOneWidget);
    expect(
      find.textContaining('ana@example.com', findRichText: true),
      findsOne,
    );
    expect(api.last('POST /auth/password/request').body, {
      'email': 'ana@example.com',
    });
  });

  testWidgets('e-mail inválido mostra erro no campo', (tester) async {
    api.responses['POST /auth/password/request'] = FakeAuthApi.errors({
      'email': 'Informe um e-mail válido.',
    });
    await pumpForgot(tester);

    await tester.enterText(textField('E-mail'), 'ana');
    await tester.tap(find.widgetWithText(AppButton, 'Enviar código'));
    await tester.pumpAndSettle();

    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.byType(ResetCodePage), findsNothing);
  });
}
