import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/term_page.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/modals/move_modal.dart';
import 'package:tagarela/features/vocabulary/vocabulary_page.dart';
import 'package:tagarela/features/vocabulary/widgets/group_card.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';

import '../../helpers/failing_stores.dart';
import '../../helpers/fake_vocabulary_api.dart';
import '../../helpers/pump_app.dart';

Json _term(String id, String text, int level, String day) => {
  'id': id,
  'text': text,
  'translation': '',
  'kind': text.contains(' ') ? 'expression' : 'word',
  'level': level,
  'created_at': '2026-10-${day}T12:00:00Z',
};

Json _group(String id, String name, List<Json> terms) => {
  'id': id,
  'name': name,
  'icon': 'travel',
  'accent': 'sky',
  'terms': terms,
};

final Json _seed = {
  'groups': [
    _group('viagem', 'Viagem', [
      _term('t1', 'layover', 5, '10'),
      _term('t2', 'jet lag', 1, '30'),
    ]),
    _group('musica', 'Música', []),
  ],
  'ungrouped': [_term('u1', 'mind the gap', 0, '20')],
};

List<String> _shown(WidgetTester tester) => tester
    .widgetList<TermTile>(find.byType(TermTile))
    .map((t) => t.term.text)
    .toList();

Future<FakeVocabulary> _pump(WidgetTester tester, {Json? seed}) async {
  final vocabulary = fakeVocabulary(seed ?? _seed);
  await tester.pumpPage(
    const VocabularyPage(),
    deps: fakeDependencies(vocabulary: vocabulary.store),
  );
  return vocabulary;
}

Future<void> _showGroups(WidgetTester tester) async {
  await tester.tap(find.text('Grupos'));
  await tester.pump();
}

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

  testWidgets('abre em Termos com tudo, do mais novo ao mais antigo', (
    tester,
  ) async {
    await _pump(tester);

    expect(_shown(tester), ['jet lag', 'mind the gap', 'layover']);
    expect(find.byType(GroupCard), findsNothing);
  });

  testWidgets('termo de grupo mostra o grupo; solto oferece Pôr num grupo', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Viagem'), findsNWidgets(2));
    expect(find.text('Pôr num grupo'), findsOneWidget);
  });

  testWidgets('filtros trocam os termos', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Sem grupo · 1'));
    await tester.pump();
    expect(_shown(tester), ['mind the gap']);

    await tester.tap(find.text('Dominado'));
    await tester.pump();
    expect(_shown(tester), ['layover']);

    await tester.tap(find.text('Aprendendo'));
    await tester.pump();
    expect(_shown(tester), ['jet lag', 'mind the gap']);

    await tester.tap(find.text('Todos · 3'));
    await tester.pump();
    expect(_shown(tester), hasLength(3));
  });

  testWidgets(
    'sem termo solto: filtro Sem grupo diz que está tudo organizado',
    (tester) async {
      await _pump(
        tester,
        seed: {
          'groups': [
            _group('viagem', 'Viagem', [_term('t1', 'layover', 5, '10')]),
          ],
          'ungrouped': <Object?>[],
        },
      );

      await tester.tap(find.text('Sem grupo · 0'));
      await tester.pump();

      expect(find.text('Tudo organizado'), findsOneWidget);
      expect(find.byType(TermTile), findsNothing);
    },
  );

  testWidgets('toque no termo abre a ficha', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('mind the gap'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(TermPage), findsOneWidget);
  });

  testWidgets('Pôr num grupo move só aquele termo e desfaz', (tester) async {
    final (:store, :api) = await _pump(tester);

    await tester.tap(find.text('Pôr num grupo'));
    await tester.pumpAndSettle();
    expect(find.text('1 termo de Sem grupo'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(MoveModal),
        matching: find.text('Música'),
      ),
    );
    await tester.pumpUntilFound(find.text('1 termo movido'));

    expect(api.termsOf('musica'), ['mind the gap']);
    expect(find.text('Pôr num grupo'), findsNothing);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(store.data!.ungrouped.single.text, 'mind the gap');
  });

  testWidgets('seleção com termos de grupos diferentes: Desfazer devolve cada '
      'um pro seu', (tester) async {
    final (:store, :api) = await _pump(tester);

    await tester.longPress(find.text('jet lag'));
    await tester.pump();
    await tester.tap(find.text('mind the gap'));
    await tester.pump();
    expect(find.text('2 selecionados'), findsOneWidget);

    await tester.tap(find.text('Mover 2 termos'));
    await tester.pumpAndSettle();
    expect(find.text('2 termos'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(MoveModal),
        matching: find.text('Música'),
      ),
    );
    await tester.pumpUntilFound(find.text('2 termos movidos'));

    expect(api.termsOf('musica'), unorderedEquals(['jet lag', 'mind the gap']));

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(store.data!.ungrouped.map((t) => t.text), ['mind the gap']);
    expect(api.termsOf('viagem'), contains('jet lag'));
  });

  testWidgets('voltar do sistema sai da seleção, X também', (tester) async {
    await _pump(tester);

    await tester.longPress(find.text('jet lag'));
    await tester.pump();
    expect(find.byType(AppCheckbox), findsNWidgets(3));
    expect(find.byType(SegmentedControl), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AppCheckbox), findsNothing);

    await tester.longPress(find.text('jet lag'));
    await tester.pump();
    await tester.tap(find.byTooltip('Cancelar seleção'));
    await tester.pump();
    expect(find.byType(AppCheckbox), findsNothing);
  });

  testWidgets('apaga da lista selecionada e desfaz', (tester) async {
    await _pump(tester);

    await tester.longPress(find.text('layover'));
    await tester.pump();
    await tester.tap(find.text('Apagar'));
    await tester.pumpUntilFound(find.text('1 termo apagado'));

    expect(_shown(tester), ['jet lag', 'mind the gap']);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(_shown(tester), hasLength(3));
  });

  testWidgets('aba Grupos mostra um card por grupo e abre o grupo', (
    tester,
  ) async {
    final scope = await tester.pumpPage(const VocabularyPage());
    await _showGroups(tester);

    expect(
      find.byType(GroupCard),
      findsNWidgets(scope.vocabulary.data!.groups.length),
    );

    final group = scope.vocabulary.data!.groups[1];
    await tester.tap(find.text(group.name));
    await tester.pumpAndSettle();

    final page = tester.widget<GroupPage>(find.byType(GroupPage));
    expect(page.groupId, group.id);
  });

  testWidgets('sem grupos: a aba Grupos convida a criar', (tester) async {
    await _pump(
      tester,
      seed: {
        'groups': <Object?>[],
        'ungrouped': [_term('u1', 'mind the gap', 0, '20')],
      },
    );
    await _showGroups(tester);

    expect(find.text('Nenhum grupo ainda'), findsOneWidget);
    await tester.tap(find.text('Criar grupo'));
    await tester.pumpAndSettle();
    expect(find.text('Junte termos do mesmo assunto'), findsOneWidget);
  });

  testWidgets('"Novo grupo" cria, vai pra aba Grupos e avisa com "Abrir"', (
    tester,
  ) async {
    final scope = await tester.pumpPage(const VocabularyPage());

    await tester.tap(find.byTooltip('Novo grupo'));
    await tester.pumpAndSettle();
    await tester.enterText(textField('Nome'), 'Música');
    await tester.pump();
    await tester.tap(find.text('Criar grupo'));
    await tester.pumpUntilFound(find.text('Grupo criado'));

    expect(scope.vocabulary.data!.groups.first.name, 'Música');
    expect(
      tester.widgetList<GroupCard>(find.byType(GroupCard)).first.group.name,
      'Música',
    );
    expect(find.text('Música está no topo da lista.'), findsOneWidget);

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    final page = tester.widget<GroupPage>(find.byType(GroupPage));
    expect(page.groupId, scope.vocabulary.data!.groups.first.id);
  });

  testWidgets('apagar o grupo avisa e "Ver" mostra Sem grupo', (tester) async {
    final scope = await tester.pumpPage(const VocabularyPage());
    await _showGroups(tester);
    final group = scope.vocabulary.data!.groups.first;
    await tester.tap(find.text(group.name));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar grupo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apagar grupo'));
    await tester.pumpUntilFound(find.text('Grupo apagado'));

    expect(find.byType(GroupPage), findsNothing);
    expect(
      find.text('Os ${group.terms.length} termos foram pra Sem grupo.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ver'));
    await tester.pumpAndSettle();

    expect(find.byType(TermTile), findsWidgets);
    expect(find.byType(GroupCard), findsNothing);
    expect(chipSelected(tester, 'Sem grupo ·'), isTrue);
  });

  testWidgets('puxar a lista recarrega', (tester) async {
    final vocabulary = fakeVocabulary();
    await tester.pumpPage(
      const VocabularyPage(),
      deps: fakeDependencies(vocabulary: vocabulary.store),
    );
    vocabulary.api.calls.clear();

    await tester.fling(
      find.byType(SegmentedControl),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(vocabulary.api.calls, ['GET /api/v1/vocabulary']);
  });

  testWidgets('carregando: sem abas e sem contagem', (tester) async {
    await tester.pumpPage(const VocabularyPage(), load: false);

    expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
    expect(find.byType(SegmentedControl), findsNothing);
  });

  testWidgets('sem termos: estado vazio, sem contagem', (tester) async {
    await tester.pumpPage(
      const VocabularyPage(),
      deps: fakeDependencies(vocabulary: emptyVocabulary()),
    );

    expect(find.text('Nenhum termo ainda'), findsOneWidget);
    expect(
      find.text('Capture e confirme a análise pra começar.'),
      findsOneWidget,
    );
    expect(find.textContaining('termos em'), findsNothing);
    expect(find.byType(SegmentedControl), findsNothing);
  });

  testWidgets('erro: "Tentar de novo" recarrega', (tester) async {
    final vocabulary = FailingVocabularyStore();
    await tester.pumpPage(
      const VocabularyPage(),
      deps: fakeDependencies(vocabulary: vocabulary),
    );
    expect(find.byType(StateMessage), findsOneWidget);

    vocabulary.failing = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    expect(find.byType(TermTile), findsWidgets);
  });
}
