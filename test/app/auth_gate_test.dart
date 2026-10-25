import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/app/auth_gate.dart';
import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/features/auth/login_page.dart';

import '../helpers/fake_auth.dart';
import '../helpers/pump_app.dart';

void main() {
  late FakeAuthApi api;

  setUp(() => api = FakeAuthApi());

  Future<AppScope> pumpGate(
    WidgetTester tester,
    FakeTokenStorage storage,
  ) async {
    tester.useTallScreen();
    final scope = testScope(
      auth: fakeAuthStore(api: api, storage: storage),
      child: testApp(const AuthGate()),
    );
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();
    return scope;
  }

  testWidgets('sem sessão salva abre o login', (tester) async {
    await pumpGate(tester, FakeTokenStorage());

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('sessão válida abre o app com os dados', (tester) async {
    final scope = await pumpGate(tester, FakeTokenStorage('refresh-1'));

    expect(find.byType(HomeShell), findsOneWidget);
    expect(scope.home.data, isNotNull);
    expect(scope.captures.data, isEmpty);
    expect(scope.auth.user?.name, 'Ana Souza');
  });

  testWidgets('sessão recusada pela API volta pro login', (tester) async {
    final storage = FakeTokenStorage('velho');
    api.responses['POST /tokens/refresh'] = FakeAuthApi.errors({
      'refresh_token': 'Inválido.',
    });

    await pumpGate(tester, storage);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(storage.token, isNull);
  });
}
