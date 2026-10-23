import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/new_password_page.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeAuthApi api;

  setUp(() => api = FakeAuthApi());

  Future<void> save(WidgetTester tester) async {
    await tester.pumpPage(
      const NewPasswordPage(code: '482913', sessionToken: 'session-1'),
      auth: fakeAuthStore(api: api),
      load: false,
    );
    await tester.enterText(textField('Nova senha'), 'nova-s3nha-456');
    await tester.tap(find.widgetWithText(AppButton, 'Salvar e entrar'));
    await tester.pumpAndSettle();
  }

  testWidgets('salva a senha e abre o app', (tester) async {
    await save(tester);

    expect(find.byType(HomeShell), findsOneWidget);
    final request = api.last('POST /auth/password/reset');
    expect(request.body, {'key': '482913', 'password': 'nova-s3nha-456'});
    expect(request.headers['X-Session-Token'], 'session-1');
  });

  testWidgets('senha fraca mostra erro no campo', (tester) async {
    api.responses['POST /auth/password/reset'] = FakeAuthApi.errors({
      'password': 'Senha muito comum.',
    });

    await save(tester);

    expect(find.text('Senha muito comum.'), findsOneWidget);
    expect(find.byType(NewPasswordPage), findsOneWidget);
  });

  testWidgets('código expirado vira aviso', (tester) async {
    api.responses['POST /auth/password/reset'] = FakeAuthApi.errors({
      'key': 'Código expirado.',
    });

    await save(tester);

    expect(find.widgetWithText(SnackBar, 'Código expirado.'), findsOneWidget);
  });
}
