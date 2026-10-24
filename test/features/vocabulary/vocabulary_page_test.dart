import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/vocabulary_page.dart';
import 'package:tagarela/features/vocabulary/widgets/group_card.dart';

import '../../helpers/failing_stores.dart';
import '../../helpers/fake_vocabulary_api.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('header conta todos os termos e os grupos', (tester) async {
    final scope = await tester.pumpPage(const VocabularyPage());

    final vocabulary = scope.vocabulary.data!;
    expect(
      find.text(
        '${vocabulary.termCount} termos em ${vocabulary.groups.length} grupos',
      ),
      findsOneWidget,
    );
  });

  testWidgets('mostra um card por grupo', (tester) async {
    final scope = await tester.pumpPage(const VocabularyPage());

    expect(
      find.byType(GroupCard),
      findsNWidgets(scope.vocabulary.data!.groups.length),
    );
  });

  testWidgets('Sem grupo no topo abre a tela dos termos soltos', (
    tester,
  ) async {
    await tester.pumpPage(const VocabularyPage());

    expect(find.text('2 termos pra pôr num grupo'), findsOneWidget);
    await tester.tap(find.text('Organizar'));
    await tester.pumpAndSettle();

    final page = tester.widget<GroupPage>(find.byType(GroupPage));
    expect(page.groupId, isNull);
  });

  testWidgets('sem termo solto: sem o card Sem grupo', (tester) async {
    await tester.pumpPage(
      const VocabularyPage(),
      vocabulary: fakeVocabulary({
        'groups': [
          {
            'id': 'g1',
            'name': 'Viagem',
            'icon': 'travel',
            'accent': 'sky',
            'terms': <Object?>[],
          },
        ],
        'ungrouped': <Object?>[],
      }).store,
    );

    expect(find.text('Sem grupo'), findsNothing);
    expect(find.text('Sem termos ainda'), findsOneWidget);
  });

  testWidgets('só termo solto: Sem grupo e convite pra criar grupo', (
    tester,
  ) async {
    await tester.pumpPage(
      const VocabularyPage(),
      vocabulary: fakeVocabulary({
        'groups': <Object?>[],
        'ungrouped': [
          {
            'id': 'u1',
            'text': 'mind the gap',
            'translation': '',
            'kind': 'expression',
            'level': 0,
          },
        ],
      }).store,
    );

    expect(find.text('1 termo'), findsOneWidget);
    expect(find.text('Sem grupo'), findsOneWidget);
    expect(find.text('Nenhum grupo ainda'), findsOneWidget);
    expect(find.text('Seus grupos'), findsNothing);

    await tester.tap(find.text('Criar grupo'));
    await tester.pumpAndSettle();
    expect(find.text('Junte termos do mesmo assunto'), findsOneWidget);
  });

  testWidgets('toque no grupo abre GroupPage do grupo', (tester) async {
    final scope = await tester.pumpPage(const VocabularyPage());

    final group = scope.vocabulary.data!.groups[1];
    await tester.tap(find.text(group.name));
    await tester.pumpAndSettle();

    final page = tester.widget<GroupPage>(find.byType(GroupPage));
    expect(page.groupId, group.id);
  });

  testWidgets('"Novo grupo" cria, põe no topo e avisa com "Abrir"', (
    tester,
  ) async {
    final scope = await tester.pumpPage(const VocabularyPage());

    await tester.tap(find.byTooltip('Novo grupo'));
    await tester.pumpAndSettle();
    await tester.enterText(textField('Nome'), 'Música');
    await tester.pump();
    await tester.tap(find.text('Criar grupo'));
    await tester.pumpAndSettle();

    expect(scope.vocabulary.data!.groups.first.name, 'Música');
    expect(
      tester.widgetList<GroupCard>(find.byType(GroupCard)).first.group.name,
      'Música',
    );
    expect(find.text('Grupo criado'), findsOneWidget);
    expect(find.text('Música está no topo da lista.'), findsOneWidget);

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    final page = tester.widget<GroupPage>(find.byType(GroupPage));
    expect(page.groupId, scope.vocabulary.data!.groups.first.id);
  });

  testWidgets('puxar a lista recarrega', (tester) async {
    final vocabulary = fakeVocabulary();
    await tester.pumpPage(const VocabularyPage(), vocabulary: vocabulary.store);
    vocabulary.api.calls.clear();

    await tester.fling(find.text('Seus grupos'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(vocabulary.api.calls, ['GET /api/v1/vocabulary']);
  });

  testWidgets('carregando: sem grupos e sem contagem', (tester) async {
    await tester.pumpPage(const VocabularyPage(), load: false);

    expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
    expect(find.byType(GroupCard), findsNothing);
  });

  testWidgets('sem termos: estado vazio, sem contagem', (tester) async {
    await tester.pumpPage(
      const VocabularyPage(),
      vocabulary: emptyVocabulary(),
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
