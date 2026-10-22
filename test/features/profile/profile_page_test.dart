import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/profile/profile_page.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra dados do usuário', (tester) async {
    final scope = await tester.pumpPage(const ProfilePage());

    final user = scope.user.data!;
    expect(find.text(user.name), findsOneWidget);
    expect(find.text(user.email), findsOneWidget);
    expect(find.text(user.initials), findsOneWidget);
  });

  testWidgets('"Sair" volta ao login e limpa a pilha', (tester) async {
    await tester.pumpPage(const ProfilePage());

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(ProfilePage), findsNothing);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });
}
