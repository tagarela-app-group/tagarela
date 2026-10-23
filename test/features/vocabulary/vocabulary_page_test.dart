import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/vocabulary_page.dart';
import 'package:tagarela/features/vocabulary/widgets/group_card.dart';

import 'package:tagarela/data/stores/vocabulary_store.dart';

import '../../helpers/failing_stores.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('header conta termos e grupos', (tester) async {
    final scope = await tester.pumpPage(const VocabularyPage());

    final groups = scope.vocabulary.data!;
    expect(
      find.text('${groups.termCount} termos em ${groups.length} grupos'),
      findsOneWidget,
    );
  });

  testWidgets('mostra um card por grupo', (tester) async {
    final scope = await tester.pumpPage(const VocabularyPage());

    expect(
      find.byType(GroupCard),
      findsNWidgets(scope.vocabulary.data!.length),
    );
  });

  testWidgets('toque no grupo abre GroupPage do grupo', (tester) async {
    final scope = await tester.pumpPage(const VocabularyPage());

    final group = scope.vocabulary.data![1];
    await tester.tap(find.text(group.name));
    await tester.pumpAndSettle();

    final page = tester.widget<GroupPage>(find.byType(GroupPage));
    expect(page.group, same(group));
  });

  testWidgets('carregando: sem grupos e sem contagem', (tester) async {
    await tester.pumpPage(const VocabularyPage(), load: false);

    expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
    expect(find.byType(GroupCard), findsNothing);
  });

  testWidgets('sem termos: estado vazio, sem contagem', (tester) async {
    await tester.pumpPage(
      const VocabularyPage(),
      vocabulary: VocabularyStore(),
    );

    expect(find.text('Nenhum termo ainda'), findsOneWidget);
    expect(
      find.text('Capture e confirme a análise pra começar.'),
      findsOneWidget,
    );
    expect(find.textContaining('termos em'), findsNothing);
    expect(find.byType(GroupCard), findsNothing);
  });

  testWidgets('erro: "Tentar de novo" recarrega', (tester) async {
    final vocabulary = FailingVocabularyStore();
    await tester.pumpPage(const VocabularyPage(), vocabulary: vocabulary);
    expect(find.byType(StateMessage), findsOneWidget);

    vocabulary.failing = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    expect(find.byType(GroupCard), findsWidgets);
  });
}
