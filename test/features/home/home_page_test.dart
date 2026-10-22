import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/home_page.dart';
import 'package:tagarela/features/home/widgets/review_card.dart';
import 'package:tagarela/features/home/widgets/vocabulary_summary.dart';
import 'package:tagarela/features/home/widgets/word_of_day_card.dart';

import '../../helpers/fake_api_client.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('header saúda o usuário e mostra a sequência', (tester) async {
    final scope = await tester.pumpPage(HomePage(onSeeVocabulary: () {}));

    final user = scope.user.data!;
    expect(find.text('Bom dia, ${user.name}'), findsOneWidget);
    expect(find.text(user.initials), findsOneWidget);
    expect(
      find.bySemanticsLabel('Sequência de ${user.streakDays} dias'),
      findsOneWidget,
    );
  });

  testWidgets('mostra palavra do dia, resumo e revisão', (tester) async {
    final scope = await tester.pumpPage(HomePage(onSeeVocabulary: () {}));

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
    final scope = await tester.pumpPage(HomePage(onSeeVocabulary: () {}));

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
    await tester.pumpPage(HomePage(onSeeVocabulary: () => taps++));

    await tester.tap(find.text('Ver tudo'));
    expect(taps, 1);
  });

  testWidgets('espera todos os stores; erro tenta de novo', (tester) async {
    final api = FakeApiClient()..failing = true;
    await tester.pumpPage(HomePage(onSeeVocabulary: () {}), api: api);
    expect(find.byType(WordOfDayCard), findsNothing);
    expect(find.text('Não deu pra carregar'), findsOneWidget);

    api.failing = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    expect(find.byType(WordOfDayCard), findsOneWidget);
    expect(find.byType(StateMessage), findsNothing);
  });
}
