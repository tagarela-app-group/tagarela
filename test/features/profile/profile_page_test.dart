import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/profile/profile_page.dart';
import 'package:tagarela/features/profile/widgets/progress_card.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_capture_store.dart';
import '../../helpers/fake_extraction.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('topo centralizado: avatar grande com anel, nome e e-mail', (
    tester,
  ) async {
    await tester.pumpPage(const ProfilePage(), auth: await signedInAuthStore());

    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('ana@example.com'), findsNWidgets(2));
    expect(find.text('AS'), findsOneWidget);
    final bubble = tester.widget<AppBubble>(find.byType(AppBubble));
    expect(bubble.image, isNotNull);
    expect(bubble.size, 84);
    expect(bubble.ring, isNotNull);
    expect(tester.widget<PageHeader>(find.byType(PageHeader)).centered, isTrue);
  });

  testWidgets('progresso: capturas, termos e dominados', (tester) async {
    final captures = fakeCaptures();
    await captures.db.saveCapture('ana@example.com', sampleCapture('c1'));
    await captures.db.saveCapture('ana@example.com', sampleCapture('c2'));
    await tester.pumpPage(
      const ProfilePage(),
      auth: await signedInAuthStore(),
      captures: captures.store,
    );

    final card = tester.widget<ProgressCard>(find.byType(ProgressCard));
    expect(card.captures, 2);
    expect(card.terms, sampleGroups.termCount);
    expect(card.mastered, sampleGroups.masteredCount);
    expect(find.text('Capturas'), findsOneWidget);
    expect(find.text('Termos'), findsOneWidget);
    expect(find.text('Dominados'), findsOneWidget);
  });

  testWidgets('sem vocabulário: progresso zerado', (tester) async {
    await tester.pumpPage(
      const ProfilePage(),
      auth: await signedInAuthStore(),
      vocabulary: VocabularyStore(),
    );

    final card = tester.widget<ProgressCard>(find.byType(ProgressCard));
    expect((card.captures, card.terms, card.mastered), (0, 0, 0));
  });

  testWidgets('sem usuário mostra só o título, o progresso e o "Sair"', (
    tester,
  ) async {
    await tester.pumpPage(const ProfilePage());

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.byType(ProgressCard), findsOneWidget);
    expect(find.text('CONTA'), findsNothing);
    expect(find.text('Sair'), findsOneWidget);
  });

  group('Funciona sem internet', () {
    testWidgets('baixa o modelo sozinho, sem botão, e fica pronto', (
      tester,
    ) async {
      final speech = fakeSpeechModel();
      speech.storage
        ..steps = const [0.42]
        ..hold = Completer();
      await tester.pumpPage(
        const ProfilePage(),
        auth: await signedInAuthStore(),
        captures: fakeCaptures(extractor: FakeTextExtractor()).store,
        speech: speech.store,
      );
      await tester.pump();

      expect(find.text('FUNCIONA SEM INTERNET'), findsOneWidget);
      expect(find.text('Texto de fotos'), findsOneWidget);
      expect(find.text('Áudio em inglês'), findsOneWidget);
      expect(find.text('Baixando'), findsOneWidget);
      expect(find.text('Baixando o modelo: 42% de 45 MB'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Privacidade'), findsOneWidget);

      speech.storage.hold!.complete();
      await tester.pumpAndSettle();

      expect(find.text('Pronto'), findsNWidgets(2));
      expect(
        find.text('Transcrito no celular · modelo de 45 MB'),
        findsOneWidget,
      );
    });

    testWidgets('sem rede: esperando, sem botão de tentar', (tester) async {
      final speech = fakeSpeechModel();
      speech.storage.offline = true;
      await tester.pumpPage(
        const ProfilePage(),
        auth: await signedInAuthStore(),
        captures: fakeCaptures(extractor: FakeTextExtractor()).store,
        speech: speech.store,
      );
      await tester.pump();

      expect(find.text('Esperando'), findsOneWidget);
      expect(
        find.text('O modelo de 45 MB baixa sozinho quando tiver internet'),
        findsOneWidget,
      );
      expect(find.byType(AppButton), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      speech.store.dispose();
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

    await tester.ensureVisible(find.text('Sair'));
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
