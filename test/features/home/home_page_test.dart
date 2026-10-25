import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/home_page.dart';
import 'package:tagarela/features/home/widgets/review_card.dart';
import 'package:tagarela/features/home/widgets/vocabulary_summary.dart';
import 'package:tagarela/features/home/widgets/word_of_day_card.dart';

import 'package:tagarela/data/stores/home_store.dart';

import '../../helpers/fake_vocabulary_api.dart';
import '../../helpers/failing_stores.dart';
import '../../helpers/fake_auth.dart';
import '../../helpers/l10n.dart';
import '../../helpers/pump_app.dart';

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
    final bubble = tester.widget<AppBubble>(find.byType(AppBubble));
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
      home.stats.reviewCount,
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
    );

    expect(find.byType(WordOfDayCard), findsNothing);
    expect(find.byType(ReviewCard), findsNothing);
    expect(find.byType(VocabularySummary), findsNothing);
    expect(find.text('Seu inglês começa aqui'), findsOneWidget);
    expect(find.byType(SpeechBubbleIcon), findsOneWidget);
    expect(tester.widget<SheetPage>(find.byType(SheetPage)).centerLast, isTrue);

    await tester.tap(find.text('Fazer a primeira captura'));
    expect(captures, 1);
  });

  testWidgets('só com revisão pendente: tela normal, sem o aviso', (
    tester,
  ) async {
    await tester.pumpPage(
      HomePage(onSeeVocabulary: () {}, onCapture: () {}),
      home: HomeStore((
        stats: const Stats(weekGain: 0, reviewCount: 3),
        wordOfDay: null,
      )),
      vocabulary: emptyVocabulary(),
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
}
