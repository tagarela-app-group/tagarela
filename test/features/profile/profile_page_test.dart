import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/profile/profile_page.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_extraction.dart';
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

  group('Transcrição offline', () {
    testWidgets('sem modelo: baixar mostra o progresso e fica pronto', (
      tester,
    ) async {
      final speech = fakeSpeechModel();
      speech.storage
        ..steps = const [0.42]
        ..hold = Completer();
      await tester.pumpPage(const ProfilePage(), speech: speech.store);

      expect(find.text('Transcrição offline'), findsOneWidget);
      expect(find.text('Não baixado'), findsOneWidget);
      expect(
        find.text('Transcreve o áudio no celular, sem internet. 45 MB.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Baixar modelo'));
      await tester.pump();

      expect(find.text('Baixando'), findsOneWidget);
      expect(find.text('Baixando 42% de 45 MB.'), findsOneWidget);
      expect(find.byType(SegmentBar), findsOneWidget);
      expect(find.text('Baixar modelo'), findsNothing);

      speech.storage.hold!.complete();
      await tester.pumpAndSettle();

      expect(find.text('Pronto'), findsOneWidget);
      expect(
        find.text('O áudio é transcrito no celular. 45 MB.'),
        findsOneWidget,
      );
      expect(find.byType(SegmentBar), findsNothing);
    });

    testWidgets('pronto: remover volta pra baixar', (tester) async {
      final speech = fakeSpeechModel(ready: true);
      await tester.pumpPage(const ProfilePage(), speech: speech.store);

      await tester.tap(find.text('Remover modelo'));
      await tester.pumpAndSettle();

      expect(speech.storage.removed, 1);
      expect(find.text('Baixar modelo'), findsOneWidget);
    });

    testWidgets('erro no download: tentar de novo', (tester) async {
      final speech = fakeSpeechModel();
      speech.storage.offline = true;
      await tester.pumpPage(const ProfilePage(), speech: speech.store);

      await tester.tap(find.text('Baixar modelo'));
      await tester.pumpAndSettle();

      expect(find.text('Erro'), findsOneWidget);
      expect(
        find.text('Não deu pra baixar. Confira a internet.'),
        findsOneWidget,
      );

      speech.storage.offline = false;
      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(find.text('Pronto'), findsOneWidget);
    });
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
