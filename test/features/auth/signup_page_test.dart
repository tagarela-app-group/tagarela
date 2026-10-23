import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/auth/signup_page.dart';
import 'package:tagarela/features/auth/verify_email_page.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeAuthApi api;

  setUp(() => api = FakeAuthApi());

  Future<void> pumpSignup(WidgetTester tester) => tester.pumpPage(
    const SignupPage(),
    auth: fakeAuthStore(api: api),
    load: false,
  );

  Future<void> signup(WidgetTester tester) async {
    await tester.enterText(textField('Nome'), ' Ana Souza ');
    await tester.enterText(textField('E-mail'), 'ana@example.com');
    await tester.enterText(textField('Senha'), 's3nha-forte');
    await tester.tap(find.widgetWithText(AppButton, 'Criar conta'));
    await tester.pumpAndSettle();
  }

  testWidgets('mostra dica da senha', (tester) async {
    await pumpSignup(tester);

    expect(find.text('Mínimo de 8 caracteres.'), findsOneWidget);
  });

  testWidgets('cria conta e vai pro código com o e-mail', (tester) async {
    await pumpSignup(tester);

    await signup(tester);

    expect(find.byType(VerifyEmailPage), findsOneWidget);
    expect(
      find.textContaining('ana@example.com', findRichText: true),
      findsOne,
    );
    expect(api.last('POST /auth/signup').body, {
      'name': 'Ana Souza',
      'email': 'ana@example.com',
      'password': 's3nha-forte',
    });
  });

  testWidgets('erros aparecem nos campos', (tester) async {
    api.responses['POST /auth/signup'] = FakeAuthApi.errors({
      'name': 'Campo obrigatório.',
      'password': 'Senha muito curta.',
    });
    await pumpSignup(tester);

    await signup(tester);

    expect(find.text('Campo obrigatório.'), findsOneWidget);
    expect(find.text('Senha muito curta.'), findsOneWidget);
    expect(find.text('Mínimo de 8 caracteres.'), findsNothing);
  });

  testWidgets('Google no cadastro entra no app', (tester) async {
    await pumpSignup(tester);

    await tester.tap(find.text('Continuar com Google'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('"Entrar" volta pro login', (tester) async {
    await tester.pumpPage(const LoginPage(), load: false);
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(AppButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupPage), findsNothing);
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
