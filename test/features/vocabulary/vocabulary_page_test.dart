import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/vocabulary_page.dart';
import 'package:tagarela/features/vocabulary/widgets/group_card.dart';

import '../../helpers/fake_api_client.dart';
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

  testWidgets('erro: "Tentar de novo" recarrega', (tester) async {
    final api = FakeApiClient()..failing = true;
    await tester.pumpPage(const VocabularyPage(), api: api);
    expect(find.byType(StateMessage), findsOneWidget);

    api.failing = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    expect(find.byType(GroupCard), findsWidgets);
  });
}
