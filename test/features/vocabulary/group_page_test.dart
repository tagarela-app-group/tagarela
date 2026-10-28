import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/modals/group_modal.dart';
import 'package:tagarela/features/vocabulary/modals/move_modal.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';

import '../../helpers/fake_vocabulary_api.dart';
import '../../helpers/open_modal.dart';
import '../../helpers/pump_app.dart';

Json _term(String id, String text, int level) => {
  'id': id,
  'text': text,
  'translation': '',
  'kind': text.contains(' ') ? 'expression' : 'word',
  'level': level,
};

Json _group(String id, String name, List<Json> terms) => {
  'id': id,
  'name': name,
  'icon': 'travel',
  'accent': 'sky',
  'terms': terms,
};

final _seed = <String, Object?>{
  'groups': [
    _group('viagem', 'Viagem', [
      _term('t1', 'layover', 5),
      _term('t2', 'carry-on', 2),
      _term('t3', 'jet lag', 1),
    ]),
    _group('musica', 'Música', []),
  ],
  'ungrouped': [_term('u1', 'mind the gap', 0), _term('u2', 'stand clear', 0)],
};

Finder _option(String label) => find.descendant(
  of: find.byType(SegmentedControl),
  matching: find.text(label),
);

List<String> _shownTerms(WidgetTester tester) => tester
    .widgetList<TermTile>(find.byType(TermTile))
    .map((t) => t.term.text)
    .toList();

Future<FakeVocabulary> _open(
  WidgetTester tester,
  GroupPage page, {
  Json? seed,
}) async {
  final vocabulary = fakeVocabulary(seed ?? _seed);
  await tester.pumpPage(
    Builder(
      builder: (context) => TextButton(
        onPressed: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
        child: const Text('Abrir'),
      ),
    ),
    deps: fakeDependencies(vocabulary: vocabulary.store),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
  return vocabulary;
}

Future<void> _startSelection(WidgetTester tester) async {
  await _menu(tester, 'Selecionar termos');
}

Future<void> _menu(WidgetTester tester, String option) async {
  await tester.tap(find.byTooltip('Mais opções'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('header resume o grupo', (tester) async {
    await _open(tester, const GroupPage(groupId: 'viagem'));

    expect(find.text('Viagem'), findsOneWidget);
    expect(find.text('3 termos · 1 dominados'), findsOneWidget);
    expect(find.bySemanticsLabel('2 aprendendo, 1 dominados'), findsOneWidget);
  });

  testWidgets('filtra por todos, aprendendo e dominado', (tester) async {
    await _open(tester, const GroupPage(groupId: 'viagem'));
    expect(_shownTerms(tester), ['layover', 'carry-on', 'jet lag']);

    await tester.tap(_option('Aprendendo'));
    await tester.pump();
    expect(_shownTerms(tester), ['carry-on', 'jet lag']);

    await tester.tap(_option('Dominado'));
    await tester.pump();
    expect(_shownTerms(tester), ['layover']);

    await tester.tap(_option('Todos · 3'));
    await tester.pump();
    expect(_shownTerms(tester), hasLength(3));
  });

  testWidgets('"Voltar" fecha a tela', (tester) async {
    await _open(tester, const GroupPage(groupId: 'viagem'));

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupPage), findsNothing);
  });

  testWidgets('grupo sem termos: estado vazio, sem filtro, menu sem seleção', (
    tester,
  ) async {
    await _open(tester, const GroupPage(groupId: 'musica'));

    expect(find.text('Nenhum termo ainda'), findsOneWidget);
    expect(find.text('Nenhum termo aqui ainda'), findsOneWidget);
    expect(find.byType(SegmentedControl), findsNothing);

    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();

    expect(find.text('Editar grupo'), findsOneWidget);
    expect(find.text('Apagar grupo'), findsOneWidget);
    expect(find.text('Selecionar termos'), findsNothing);
  });

  testWidgets('Sem grupo: dica, sem filtro, "Selecionar" no topo', (
    tester,
  ) async {
    await _open(tester, const GroupPage.ungrouped());

    expect(find.text('Sem grupo'), findsOneWidget);
    expect(find.text('2 termos pra pôr num grupo'), findsOneWidget);
    expect(find.textContaining('Mova cada um pro grupo dele.'), findsOneWidget);
    expect(find.byType(SegmentedControl), findsNothing);
    expect(_shownTerms(tester), ['mind the gap', 'stand clear']);

    await tester.tap(find.text('Selecionar'));
    await tester.pump();

    expect(find.text('Toque nos termos pra escolher'), findsOneWidget);
  });

  testWidgets('Sem grupo vazio: tudo organizado', (tester) async {
    await _open(
      tester,
      const GroupPage.ungrouped(),
      seed: {'groups': <Object?>[], 'ungrouped': <Object?>[]},
    );

    expect(find.text('Tudo organizado'), findsOneWidget);
    expect(find.text('Selecionar'), findsNothing);
  });

  testWidgets('seleção: marca, conta e libera o botão de mover', (
    tester,
  ) async {
    await _open(tester, const GroupPage(groupId: 'viagem'));
    await _startSelection(tester);

    expect(find.text('Toque nos termos pra escolher'), findsOneWidget);
    expect(button(tester, 'Selecione os termos').onPressed, isNull);
    expect(find.byType(AppCheckbox), findsNWidgets(3));

    await tester.tap(find.text('carry-on'));
    await tester.pump();
    expect(find.text('1 selecionado'), findsOneWidget);
    expect(button(tester, 'Mover 1 termo').onPressed, isNotNull);

    await tester.tap(find.text('jet lag'));
    await tester.pump();
    expect(find.text('2 selecionados'), findsOneWidget);

    await tester.tap(find.text('jet lag'));
    await tester.pump();
    expect(find.text('1 selecionado'), findsOneWidget);
  });

  testWidgets('"Selecionar todos" marca os termos do filtro', (tester) async {
    await _open(tester, const GroupPage(groupId: 'viagem'));
    await tester.tap(_option('Aprendendo'));
    await tester.pump();
    await _startSelection(tester);

    await tester.tap(find.text('Selecionar todos'));
    await tester.pump();

    expect(find.text('2 selecionados'), findsOneWidget);
  });

  testWidgets('X e voltar do sistema saem da seleção, não da tela', (
    tester,
  ) async {
    await _open(tester, const GroupPage(groupId: 'viagem'));
    await _startSelection(tester);

    await tester.tap(find.byTooltip('Cancelar seleção'));
    await tester.pump();
    expect(find.byType(AppCheckbox), findsNothing);
    expect(find.text('3 termos · 1 dominados'), findsOneWidget);

    await _startSelection(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AppCheckbox), findsNothing);
    expect(find.byType(GroupPage), findsOneWidget);
  });

  testWidgets('move pra outro grupo e desfaz', (tester) async {
    final (store: _, :api) = await _open(
      tester,
      const GroupPage(groupId: 'viagem'),
    );
    await _startSelection(tester);
    await tester.tap(find.text('carry-on'));
    await tester.tap(find.text('jet lag'));
    await tester.pump();

    await tester.tap(find.text('Mover 2 termos'));
    await tester.pumpAndSettle();
    expect(find.text('Mover pra qual grupo?'), findsOneWidget);
    expect(find.text('2 termos de Viagem'), findsOneWidget);
    final modal = find.byType(MoveModal);
    expect(
      find.descendant(of: modal, matching: find.text('Viagem')),
      findsNothing,
    );

    await tester.tap(find.descendant(of: modal, matching: find.text('Música')));
    await tester.pumpUntilFound(find.text('2 termos movidos'));

    expect(api.termsOf('musica'), unorderedEquals(['carry-on', 'jet lag']));
    expect(_shownTerms(tester), ['layover']);
    expect(find.byType(AppCheckbox), findsNothing);
    expect(find.text('2 termos movidos'), findsOneWidget);
    expect(find.text('Agora estão em Música.'), findsOneWidget);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(api.termsOf('musica'), isEmpty);
    expect(_shownTerms(tester), hasLength(3));
  });

  testWidgets('mover pra grupo novo: cria e já move', (tester) async {
    final (:store, :api) = await _open(tester, const GroupPage.ungrouped());
    await tester.tap(find.text('Selecionar'));
    await tester.pump();
    await tester.tap(find.text('mind the gap'));
    await tester.pump();

    await tester.tap(find.text('Mover 1 termo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo grupo'));
    await tester.pumpAndSettle();
    expect(find.byType(GroupModal), findsOneWidget);

    await tester.enterText(textField('Nome'), 'Metrô');
    await tester.pump();
    await tester.tap(find.text('Criar grupo'));
    await tester.pumpUntilFound(find.text('1 termo movido'));

    final metro = store.data!.groups.first;
    expect(metro.name, 'Metrô');
    expect(api.termsOf(metro.id), ['mind the gap']);
    expect(_shownTerms(tester), ['stand clear']);
    expect(find.text('1 termo movido'), findsOneWidget);
    expect(find.text('Agora está em Metrô.'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('1 termo movido'), findsNothing);
  });

  testWidgets('sem outro grupo: o seletor convida a criar', (tester) async {
    await _open(
      tester,
      const GroupPage(groupId: 'viagem'),
      seed: {
        'groups': [
          _group('viagem', 'Viagem', [_term('t1', 'layover', 5)]),
        ],
        'ungrouped': <Object?>[],
      },
    );
    await _startSelection(tester);
    await tester.tap(find.text('layover'));
    await tester.pump();

    await tester.tap(find.text('Mover 1 termo'));
    await tester.pumpAndSettle();

    expect(find.text('Você ainda não tem grupos'), findsOneWidget);
    await tester.tap(find.text('Criar grupo'));
    await tester.pumpAndSettle();
    expect(find.byType(GroupModal), findsOneWidget);
  });

  testWidgets('sem rede: avisa e mantém a seleção', (tester) async {
    final (store: _, :api) = await _open(
      tester,
      const GroupPage(groupId: 'viagem'),
    );
    await _startSelection(tester);
    await tester.tap(find.text('carry-on'));
    await tester.pump();
    await tester.tap(find.text('Mover 1 termo'));
    await tester.pumpAndSettle();
    api.offline = true;

    await tester.tap(
      find.descendant(
        of: find.byType(MoveModal),
        matching: find.text('Música'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Não deu pra mover agora. Confira a internet e tente de novo.'),
      findsOneWidget,
    );
    expect(find.text('1 selecionado'), findsOneWidget);
    expect(api.termsOf('viagem'), hasLength(3));
  });

  testWidgets('segurar um termo liga a seleção com ele marcado', (
    tester,
  ) async {
    await _open(tester, const GroupPage(groupId: 'viagem'));

    await tester.longPress(find.text('carry-on'));
    await tester.pump();

    expect(find.text('1 selecionado'), findsOneWidget);
    expect(find.byType(AppCheckbox), findsNWidgets(3));
    expect(find.text('Mover 1 termo'), findsOneWidget);
  });

  testWidgets('apaga termos e desfaz', (tester) async {
    final (store: _, :api) = await _open(
      tester,
      const GroupPage(groupId: 'viagem'),
    );
    await tester.longPress(find.text('carry-on'));
    await tester.pump();
    await tester.tap(find.text('jet lag'));
    await tester.pump();

    await tester.tap(find.text('Apagar'));
    await tester.pumpUntilFound(find.text('2 termos apagados'));

    expect(api.termsOf('viagem'), ['layover']);
    expect(_shownTerms(tester), ['layover']);
    expect(find.byType(AppCheckbox), findsNothing);
    expect(find.text('2 termos apagados'), findsOneWidget);
    expect(find.text('Saíram do vocabulário.'), findsOneWidget);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(api.calls.last, 'POST /api/v1/terms/restore');
    expect(_shownTerms(tester), hasLength(3));
  });

  testWidgets('apagar sem rede: avisa e mantém a seleção', (tester) async {
    final (store: _, :api) = await _open(
      tester,
      const GroupPage(groupId: 'viagem'),
    );
    await tester.longPress(find.text('carry-on'));
    await tester.pump();
    api.offline = true;

    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não deu pra apagar agora. Confira a internet e tente de novo.',
      ),
      findsOneWidget,
    );
    expect(find.text('1 selecionado'), findsOneWidget);
    expect(api.termsOf('viagem'), hasLength(3));
  });

  testWidgets('editar grupo: painel preenchido, salva e o header muda', (
    tester,
  ) async {
    final (store: _, :api) = await _open(
      tester,
      const GroupPage(groupId: 'viagem'),
    );

    await _menu(tester, 'Editar grupo');

    expect(find.byType(GroupModal), findsOneWidget);
    expect(find.text('Editar grupo'), findsOneWidget);
    await tester.enterText(textField('Nome'), 'Viagens');
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupModal), findsNothing);
    expect(api.bodies['PATCH /api/v1/groups/viagem'], {
      'name': 'Viagens',
      'icon': 'travel',
      'accent': 'sky',
    });
    expect(find.text('Viagens'), findsOneWidget);
  });

  testWidgets('apagar grupo: confirma, fecha a tela e os termos vão pra '
      'Sem grupo', (tester) async {
    final (store: _, :api) = await _open(
      tester,
      const GroupPage(groupId: 'viagem'),
    );

    await _menu(tester, 'Apagar grupo');

    expect(find.text('Apagar Viagem?'), findsOneWidget);
    expect(find.text('Os 3 termos voltam pra Sem grupo.'), findsOneWidget);
    await tester.tap(find.text('Apagar grupo'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupPage), findsNothing);
    expect(api.groups.map((g) => g['id']), isNot(contains('viagem')));
    expect(api.termsOf(null), containsAll(['carry-on', 'jet lag', 'layover']));
  });

  testWidgets('apagar grupo sem rede: avisa no painel e fica', (tester) async {
    final (store: _, :api) = await _open(
      tester,
      const GroupPage(groupId: 'viagem'),
    );
    await _menu(tester, 'Apagar grupo');
    api.offline = true;

    await tester.tap(find.text('Apagar grupo'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não deu pra apagar agora. Confira a internet e tente de novo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Apagar Viagem?'), findsOneWidget);
    expect(api.groups.map((g) => g['id']), contains('viagem'));
  });
}
