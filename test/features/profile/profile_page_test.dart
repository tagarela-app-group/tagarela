import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/profile/profile_page.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra nome, e-mail e avatar do usuário logado', (tester) async {
    await tester.pumpPage(const ProfilePage(), auth: await signedInAuthStore());

    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('AS'), findsOneWidget);
    expect(tester.widget<AppBubble>(find.byType(AppBubble)).image, isNotNull);
  });

  testWidgets('sem usuário mostra só o título e o "Sair"', (tester) async {
    await tester.pumpPage(const ProfilePage());

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
  });

  testWidgets('"Sair" encerra a sessão, volta ao login e limpa a pilha', (
    tester,
  ) async {
    final api = FakeAuthApi();
    final storage = FakeTokenStorage();
    final auth = fakeAuthStore(api: api, storage: storage);
    await auth.login('ana@example.com', 'x');
    await tester.pumpPage(const ProfilePage(), auth: auth);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(ProfilePage), findsNothing);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
    expect(storage.token, isNull);
    expect(api.routes, contains('DELETE /auth/session'));
  });
}
