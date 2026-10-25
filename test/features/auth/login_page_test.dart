import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/forgot_password_page.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/auth/signup_page.dart';
import 'package:tagarela/features/auth/verify_email_page.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/l10n.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeAuthApi api;
  late FakeSocialSignIn social;

  setUp(() {
    api = FakeAuthApi();
    social = FakeSocialSignIn();
  });

  Future<void> pumpLogin(WidgetTester tester) => tester.pumpPage(
    const LoginPage(),
    auth: fakeAuthStore(api: api, social: social),
    load: false,
  );

  Future<void> login(WidgetTester tester) async {
    await tester.enterText(textField('E-mail'), ' ana@example.com ');
    await tester.enterText(textField('Senha'), 's3nha-forte');
    await tester.tap(find.widgetWithText(AppButton, 'Entrar'));
    await tester.pumpAndSettle();
  }

  AppButton button(WidgetTester tester, String label) =>
      tester.widget<AppButton>(find.widgetWithText(AppButton, label));

  void expectInApp(WidgetTester tester) {
    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      false,
    );
  }

  testWidgets('mostra campos e Google; sem Apple fora do iOS', (tester) async {
    await pumpLogin(tester);

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);
    expect(find.text('Continuar com a Apple'), findsNothing);
  });

  testWidgets(
    'no iOS mostra Apple e entra com ela',
    (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Continuar com a Apple'));
      await tester.pumpAndSettle();

      expectInApp(tester);
      expect(
        (api.last('POST /auth/provider/token').body! as Map)['provider'],
        'apple',
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('"Entrar" manda e-mail sem espaço e abre o app', (tester) async {
    await pumpLogin(tester);

    await login(tester);

    expectInApp(tester);
    expect(api.last('POST /auth/login').body, {
      'email': 'ana@example.com',
      'password': 's3nha-forte',
    });
  });

  testWidgets('senha errada mostra erro no campo', (tester) async {
    api.responses['POST /auth/login'] = FakeAuthApi.errors({
      'password': 'E-mail ou senha incorretos.',
    });
    await pumpLogin(tester);

    await login(tester);

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('e-mail não verificado leva pro código', (tester) async {
    api.responses['POST /auth/login'] = FakeAuthApi.pending('verify_email');
    await pumpLogin(tester);

    await login(tester);

    expect(find.byType(VerifyEmailPage), findsOneWidget);
    expect(
      find.textContaining('ana@example.com', findRichText: true),
      findsOne,
    );
  });

  testWidgets('falha do login vira aviso no idioma do app', (tester) async {
    api.responses['POST /auth/login'] = const ApiResponse(429, null);
    await tester.pumpPage(
      const LoginPage(),
      auth: fakeAuthStore(api: api, social: social),
      load: false,
      locale: const Locale('en'),
    );

    await tester.enterText(textField('Email'), 'ana@example.com');
    await tester.enterText(textField('Password'), 's3nha-forte');
    await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text(en.authFailure('tooManyAttempts')), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('sem conexão avisa e fica no login', (tester) async {
    api.error = const SocketException('offline');
    await pumpLogin(tester);

    await login(tester);

    expect(find.text(pt.authOffline), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Google entra no app', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Continuar com Google'));
    await tester.pumpAndSettle();

    expectInApp(tester);
  });

  testWidgets('Google cancelado fica no login sem aviso', (tester) async {
    social.googleToken = null;
    await pumpLogin(tester);

    await tester.tap(find.text('Continuar com Google'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('falha no Google avisa', (tester) async {
    social.error = Exception('sem client id');
    await pumpLogin(tester);

    await tester.tap(find.text('Continuar com Google'));
    await tester.pumpAndSettle();

    expect(
      find.text('Não deu pra entrar com o Google. Tente de novo.'),
      findsOneWidget,
    );
  });

  testWidgets('"Entrar" mostra loading e trava o Google até responder', (
    tester,
  ) async {
    api.hold = Completer();
    await pumpLogin(tester);

    await tester.enterText(textField('E-mail'), 'ana@example.com');
    await tester.enterText(textField('Senha'), 's3nha-forte');
    await tester.tap(find.widgetWithText(AppButton, 'Entrar'));
    await tester.pump();

    expect(button(tester, 'Entrar').loading, isTrue);
    expect(button(tester, 'Continuar com Google').loading, isFalse);
    expect(button(tester, 'Continuar com Google').onPressed, isNull);

    api.hold!.complete();
    await tester.pumpAndSettle();
    expectInApp(tester);
  });

  testWidgets('Google mostra loading só no botão dele', (tester) async {
    api.hold = Completer();
    await pumpLogin(tester);

    await tester.tap(find.text('Continuar com Google'));
    await tester.pump();

    expect(button(tester, 'Continuar com Google').loading, isTrue);
    expect(button(tester, 'Entrar').loading, isFalse);
    expect(button(tester, 'Entrar').onPressed, isNull);

    api.hold!.complete();
    await tester.pumpAndSettle();
    expectInApp(tester);
  });

  testWidgets('Google sem configuração na API avisa', (tester) async {
    api.responses['GET /config'] = FakeAuthApi.config({});
    await pumpLogin(tester);

    await tester.tap(find.text('Continuar com Google'));
    await tester.pumpAndSettle();

    expect(find.text('Esse login não está disponível agora.'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('"Esqueci minha senha" leva o e-mail digitado', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(textField('E-mail'), 'ana@example.com');
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordPage), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
  });

  testWidgets('"Criar conta" abre o cadastro', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupPage), findsOneWidget);
  });
}
