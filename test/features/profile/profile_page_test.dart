import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/profile/profile_page.dart';
import 'package:tagarela/features/profile/widgets/progress_card.dart';
import 'package:tagarela/features/profile/widgets/user_avatar.dart';

import '../../helpers/fake_vocabulary_api.dart';
import '../../helpers/fake_auth.dart';
import '../../helpers/fake_capture_store.dart';
import '../../helpers/fake_extraction.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/fake_course_api.dart';
import 'package:tagarela/features/course/modals/course_modal.dart';

final _avatarFlag = find.descendant(
  of: find.byType(UserAvatar),
  matching: find.byType(FlagBadge),
);

void main() {
  testWidgets('topo centralizado: avatar grande com anel, nome e e-mail', (
    tester,
  ) async {
    await tester.pumpPage(const ProfilePage(), auth: await signedInAuthStore());

    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('ana@example.com'), findsNWidgets(2));
    expect(find.text('AS'), findsOneWidget);
    final bubble = tester.widget<AppBubble>(
      find.descendant(
        of: find.byType(UserAvatar),
        matching: find.byType(AppBubble),
      ),
    );
    expect(bubble.image, isNotNull);
    expect(bubble.size, 84);
    expect(bubble.ring, isNotNull);
    expect(tester.widget<PageHeader>(find.byType(PageHeader)).centered, isTrue);
  });

  testWidgets('progresso: termos, aprendendo e dominados', (tester) async {
    await tester.pumpPage(const ProfilePage(), auth: await signedInAuthStore());

    final card = tester.widget<ProgressCard>(find.byType(ProgressCard));
    expect(card.terms, sampleVocabulary.termCount);
    expect(card.learning, sampleVocabulary.learningCount);
    expect(card.mastered, sampleVocabulary.masteredCount);
    expect(find.text('Termos'), findsOneWidget);
    expect(find.text('Aprendendo'), findsOneWidget);
    expect(find.text('Dominados'), findsOneWidget);
  });

  testWidgets('sem vocabulário: progresso zerado', (tester) async {
    await tester.pumpPage(
      const ProfilePage(),
      auth: await signedInAuthStore(),
      vocabulary: emptyVocabulary(),
    );

    final card = tester.widget<ProgressCard>(find.byType(ProgressCard));
    expect((card.terms, card.learning, card.mastered), (0, 0, 0));
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

  group('País de origem', () {
    testWidgets('sem país convida a escolher e o avatar fica sem bandeira', (
      tester,
    ) async {
      await tester.pumpPage(
        const ProfilePage(),
        auth: await signedInAuthStore(),
      );

      expect(find.text('País de origem'), findsOneWidget);
      expect(
        find.text('Escolha pra mostrar a bandeira no seu avatar'),
        findsOneWidget,
      );
      expect(_avatarFlag, findsNothing);
    });

    testWidgets('busca, salva, fecha e põe a bandeira no avatar', (
      tester,
    ) async {
      final api = FakeAuthApi();
      api.responses['PATCH /api/v1/account'] = const ApiResponse(200, {
        ...FakeAuthApi.user,
        'country': 'DE',
      });
      await tester.pumpPage(
        const ProfilePage(),
        auth: await signedInAuthStore(api: api),
      );

      await tester.tap(find.text('País de origem'));
      await tester.pumpAndSettle();
      expect(find.text('Prefiro não dizer'), findsOneWidget);

      await tester.enterText(textField('Buscar país'), 'ALEM');
      await tester.pumpAndSettle();
      expect(find.text('Alemanha'), findsOneWidget);
      expect(find.text('Brasil'), findsNothing);
      expect(find.text('Prefiro não dizer'), findsNothing);

      await tester.tap(find.text('Alemanha'));
      await tester.pumpAndSettle();

      expect(api.last('PATCH /api/v1/account').body, {'country': 'DE'});
      expect(find.byType(AppModal), findsNothing);
      expect(find.text('Alemanha'), findsOneWidget);
      expect(find.bySemanticsLabel('Bandeira: Alemanha'), findsOneWidget);
    });

    testWidgets('busca sem resultado avisa', (tester) async {
      await tester.pumpPage(
        const ProfilePage(),
        auth: await signedInAuthStore(),
      );

      await tester.tap(find.text('País de origem'));
      await tester.pumpAndSettle();
      await tester.enterText(textField('Buscar país'), 'Atlântida');
      await tester.pumpAndSettle();

      expect(find.text('Nenhum país com esse nome'), findsOneWidget);
    });

    testWidgets('falha ao salvar avisa e deixa o modal aberto', (tester) async {
      final api = FakeAuthApi();
      final auth = await signedInAuthStore(api: api);
      api.responses['PATCH /api/v1/account'] = const ApiResponse(500, null);
      await tester.pumpPage(const ProfilePage(), auth: auth);

      await tester.tap(find.text('País de origem'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Afeganistão'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Não deu pra salvar o país. Confira a internet e tente de novo.',
        ),
        findsOneWidget,
      );
      expect(find.byType(AppModal), findsOneWidget);
      expect(auth.user?.country, isNull);
    });

    testWidgets('"Prefiro não dizer" limpa o país', (tester) async {
      final api = FakeAuthApi();
      final auth = await signedInAuthStore(api: api);
      await auth.updateCountry('BR');
      api.responses['PATCH /api/v1/account'] = const ApiResponse(
        200,
        FakeAuthApi.user,
      );
      await tester.pumpPage(const ProfilePage(), auth: auth);
      expect(find.text('Brasil'), findsOneWidget);
      expect(_avatarFlag, findsOneWidget);

      await tester.tap(find.text('País de origem'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Prefiro não dizer')),
        isSemantics(isSelected: false, isInMutuallyExclusiveGroup: true),
      );
      await tester.enterText(textField('Buscar país'), 'bras');
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Brasil').last),
        isSemantics(isSelected: true, isInMutuallyExclusiveGroup: true),
      );
      await tester.enterText(textField('Buscar país'), '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prefiro não dizer'));
      await tester.pumpAndSettle();

      expect(api.last('PATCH /api/v1/account').body, {'country': ''});
      expect(_avatarFlag, findsNothing);
    });
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

  testWidgets('estudo mostra o curso ativo e abre os cursos', (tester) async {
    await tester.pumpPage(const ProfilePage(), auth: await signedInAuthStore());

    expect(find.text('ESTUDO'), findsOneWidget);
    expect(find.text('Português → Inglês'), findsOneWidget);
    expect(find.text('PROGRESSO EM INGLÊS'), findsOneWidget);
    final pair = tester.widget<FlagPair>(find.byType(FlagPair));
    expect((pair.back, pair.front), ('BR', 'US'));

    await tester.tap(find.text('1 curso · trocar ou adicionar'));
    await tester.pumpAndSettle();

    expect(find.byType(CourseModal), findsOneWidget);
  });

  testWidgets('progresso segue o curso ativo', (tester) async {
    await tester.pumpPage(
      const ProfilePage(),
      auth: await signedInAuthStore(),
      courses: fakeCourses([
        {...englishCourseJson, 'active': false},
        {...spanishCourseJson, 'active': true},
      ]).store,
    );

    expect(find.text('Inglês → Espanhol'), findsOneWidget);
    expect(find.text('2 cursos · trocar ou adicionar'), findsOneWidget);
    expect(find.text('PROGRESSO EM ESPANHOL'), findsOneWidget);
  });

  testWidgets('sem a escolha de idioma do app: segue o curso', (tester) async {
    await tester.pumpPage(const ProfilePage(), auth: await signedInAuthStore());

    expect(find.text('PREFERÊNCIAS'), findsNothing);
    expect(find.text('Idioma'), findsNothing);
  });
}
