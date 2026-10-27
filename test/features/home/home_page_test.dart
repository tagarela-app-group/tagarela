import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/home_page.dart';
import 'package:tagarela/features/home/widgets/review_card.dart';
import 'package:tagarela/features/home/widgets/vocabulary_summary.dart';
import 'package:tagarela/features/home/widgets/word_of_day_card.dart';
import 'package:tagarela/features/practice/practice_page.dart';
import 'package:tagarela/features/profile/widgets/user_avatar.dart';

import 'package:tagarela/data/stores/home_store.dart';

import '../../helpers/fake_practice_api.dart';
import '../../helpers/fake_vocabulary_api.dart';
import '../../helpers/failing_stores.dart';
import '../../helpers/fake_auth.dart';
import '../../helpers/l10n.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/fake_course_api.dart';
import 'package:tagarela/features/course/modals/course_modal.dart';

void main() {
  group('greeting', () {
    test('muda com a hora do dia', () {
      String at(int hour) => greeting(pt, DateTime(2026, 10, 23, hour), 'Ana');

      expect(at(5), 'Bom dia, Ana');
      expect(at(11), 'Bom dia, Ana');
      expect(at(12), 'Boa tarde, Ana');
      expect(at(17), 'Boa tarde, Ana');
      expect(at(18), 'Boa noite, Ana');
      expect(at(4), 'Boa noite, Ana');
    });

    test('sem nome fica só a saudação', () {
      expect(greeting(pt, DateTime(2026, 10, 23, 9), ''), 'Bom dia!');
      expect(greeting(es, DateTime(2026, 10, 23, 20), ''), '¡Buenas noches!');
      expect(
        greeting(en, DateTime(2026, 10, 23, 14), 'Ana'),
        'Good afternoon, Ana',
      );
    });
  });

  testWidgets('header saúda pelo primeiro nome, com foto e iniciais', (
    tester,
  ) async {
    await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
      auth: await signedInAuthStore(),
    );

    expect(
      find.textContaining(RegExp(r'^Bo(m dia|a tarde|a noite), Ana$')),
      findsOneWidget,
    );
    expect(find.text('AS'), findsOneWidget);
    final bubble = tester.widget<AppBubble>(
      find.descendant(
        of: find.byType(UserAvatar),
        matching: find.byType(AppBubble),
      ),
    );
    expect((bubble.image as NetworkImage?)?.url, 'https://example.com/ana.png');
    expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);
  });

  testWidgets('header aparece mesmo quando os dados falham', (tester) async {
    await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
      home: FailingHomeStore(),
      auth: await signedInAuthStore(),
    );

    expect(find.textContaining(', Ana'), findsOneWidget);
    expect(find.text('Não deu pra carregar'), findsOneWidget);
  });

  testWidgets('mostra palavra do dia, resumo e revisão', (tester) async {
    final scope = await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
    );

    final home = scope.home.data!;
    expect(
      tester.widget<WordOfDayCard>(find.byType(WordOfDayCard)).word,
      same(home.wordOfDay),
    );
    expect(
      tester.widget<ReviewCard>(find.byType(ReviewCard)).count,
      scope.practice.data!.due,
    );
  });

  testWidgets('resumo usa totais do vocabulário', (tester) async {
    final scope = await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
    );

    final groups = scope.vocabulary.data!;
    final summary = tester.widget<VocabularySummary>(
      find.byType(VocabularySummary),
    );
    expect(summary.mastered, groups.masteredCount);
    expect(summary.learning, groups.learningCount);
    expect(summary.weekGain, scope.home.data!.stats.weekGain);
  });

  testWidgets('"Ver tudo" chama onSeeVocabulary', (tester) async {
    var taps = 0;
    await tester.pumpPage(
      HomePage(onSeeVocabulary: () => taps++, onCapture: () {}),
    );

    await tester.tap(find.text('Ver tudo'));
    expect(taps, 1);
  });

  testWidgets('sem nada: aviso centralizado com a primeira captura', (
    tester,
  ) async {
    var captures = 0;
    await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () => captures++),
      home: HomeStore(),
      vocabulary: emptyVocabulary(),
      practice: emptyPractice(),
    );

    expect(find.byType(WordOfDayCard), findsNothing);
    expect(find.byType(ReviewCard), findsNothing);
    expect(find.byType(VocabularySummary), findsNothing);
    expect(find.text('Seu inglês começa aqui'), findsOneWidget);
    expect(find.byType(SpeechBubbleIcon), findsOneWidget);
    expect(tester.widget<AppPage>(find.byType(AppPage)).centerLast, isTrue);

    await tester.tap(find.text('Fazer a primeira captura'));
    expect(captures, 1);
  });

  testWidgets('só com revisão pendente: tela normal, sem o aviso', (
    tester,
  ) async {
    await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
      home: HomeStore((stats: const Stats(weekGain: 0), wordOfDay: null)),
      vocabulary: emptyVocabulary(),
      practice: fakePractice(FakePracticeApi(due: 3)).store,
    );

    expect(find.byType(ReviewCard), findsOneWidget);
    expect(find.byType(VocabularySummary), findsOneWidget);
    expect(find.text('Seu inglês começa aqui'), findsNothing);
  });

  testWidgets('espera todos os stores; erro tenta de novo', (tester) async {
    final vocabulary = FailingVocabularyStore();
    await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
      vocabulary: vocabulary,
    );
    expect(find.byType(WordOfDayCard), findsNothing);
    expect(find.text('Não deu pra carregar'), findsOneWidget);

    vocabulary.failing = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    expect(find.byType(WordOfDayCard), findsOneWidget);
    expect(find.byType(StateMessage), findsNothing);
  });

  testWidgets('selo do curso mostra a bandeira do idioma e abre os cursos', (
    tester,
  ) async {
    await tester.pumpPage(HomePage(onSeeVocabulary: () {}, onCapture: () {}));

    final badge = find.bySemanticsLabel('Curso: Português → Inglês. Trocar');
    expect(badge, findsOneWidget);
    final flag = tester.widget<FlagBadge>(
      find.descendant(
        of: find.byType(HeaderPill),
        matching: find.byType(FlagBadge),
      ),
    );
    expect(flag.country, 'US');

    await tester.tap(badge);
    await tester.pumpAndSettle();

    expect(find.byType(CourseModal), findsOneWidget);
  });

  testWidgets('sem curso carregado: sem selo', (tester) async {
    final courses = fakeCourses()..api.offline = true;

    await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
      courses: courses.store,
    );

    expect(find.byType(HeaderPill), findsNothing);
  });

  testWidgets('Começar abre a revisão e, ao sair, recarrega', (tester) async {
    final practice = fakePractice();
    await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
      practice: practice.store,
    );

    await tester.tap(find.text('Começar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PracticePage), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);

    await tester.tap(find.byTooltip('Sair'));
    await tester.pumpAndSettle();

    expect(find.byType(PracticePage), findsNothing);
    expect(
      practice.api.calls.where((c) => c.startsWith('GET /api/v1/reviews')),
      hasLength(2),
    );
  });

  testWidgets('sem rodada que o app saiba jogar: Começar desligado', (
    tester,
  ) async {
    await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
      practice: fakePractice(FakePracticeApi(due: 4, rounds: [])).store,
    );

    final card = tester.widget<ReviewCard>(find.byType(ReviewCard));
    expect(card.count, 4);
    expect(card.onStart, isNull);
  });
}
