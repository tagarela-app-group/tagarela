import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/modals/group_modal.dart';
import 'package:tagarela/shared/logic/group_style.dart';

import '../../../helpers/fake_vocabulary_api.dart';
import '../../../helpers/open_modal.dart';
import '../../../helpers/pump_app.dart';

void main() {
  Future<(List<TermGroup?>, FakeVocabulary)> open(WidgetTester tester) async {
    final vocabulary = fakeVocabulary();
    await vocabulary.store.load();
    final results = await tester.openModalOf<TermGroup>(
      const GroupModal(),
      vocabulary: vocabulary.store,
    );
    return (results, vocabulary);
  }

  Future<(List<TermGroup?>, FakeVocabulary)> edit(WidgetTester tester) async {
    final vocabulary = fakeVocabulary();
    await vocabulary.store.load();
    final results = await tester.openModalOf<TermGroup>(
      GroupModal(group: vocabulary.store.data!.group('1')),
      vocabulary: vocabulary.store,
    );
    return (results, vocabulary);
  }

  IconTile preview(WidgetTester tester) =>
      tester.widgetList<IconTile>(find.byType(IconTile)).first;

  testWidgets('sem nome: botão pede o nome e fica travado', (tester) async {
    await open(tester);

    expect(button(tester, 'Dê um nome ao grupo').onPressed, isNull);
    expect(find.text('0/30'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);
  });

  testWidgets('nome que já existe: aviso e botão travado', (tester) async {
    await open(tester);

    await tester.enterText(textField('Nome'), ' viagem ');
    await tester.pump();

    expect(find.text('Você já tem um grupo com esse nome.'), findsOneWidget);
    expect(button(tester, 'Criar grupo').onPressed, isNull);
  });

  testWidgets('ícone e cor mudam a prévia do topo', (tester) async {
    await open(tester);
    expect(preview(tester).icon, GroupIcon.layers.glyph);

    await tester.tap(find.bySemanticsLabel('Música'));
    await tester.tap(find.bySemanticsLabel('Rosa'));
    await tester.pump();

    expect(preview(tester).icon, GroupIcon.music.glyph);
    expect(preview(tester).accent, AppAccent.pink);
  });

  testWidgets('cria com nome, ícone e cor e fecha com o grupo', (tester) async {
    final (results, (store: _, :api)) = await open(tester);

    await tester.enterText(textField('Nome'), '  Música ');
    await tester.tap(find.bySemanticsLabel('Música'));
    await tester.tap(find.bySemanticsLabel('Rosa'));
    await tester.pump();
    await tester.tap(find.text('Criar grupo'));
    await tester.pumpAndSettle();

    expect(api.bodies['POST /api/v1/groups'], {
      'name': 'Música',
      'icon': 'music',
      'accent': 'pink',
    });
    expect(results.single!.name, 'Música');
    expect(find.byType(GroupModal), findsNothing);
  });

  testWidgets('sem rede: erro no campo e o painel fica aberto', (tester) async {
    final (results, (store: _, :api)) = await open(tester);
    api.offline = true;

    await tester.enterText(textField('Nome'), 'Música');
    await tester.pump();
    await tester.tap(find.text('Criar grupo'));
    await tester.pumpAndSettle();

    expect(find.text('Sem conexão. Tente de novo.'), findsOneWidget);
    expect(find.byType(GroupModal), findsOneWidget);
    expect(results, isEmpty);

    await tester.enterText(textField('Nome'), 'Músicas');
    await tester.pump();
    expect(find.text('Sem conexão. Tente de novo.'), findsNothing);
  });

  testWidgets('API recusa o nome: mostra a mensagem dela', (tester) async {
    final (_, (store: _, :api)) = await open(tester);
    api.groups.insert(0, {
      'id': 'outro',
      'name': 'Música',
      'icon': 'music',
      'accent': 'pink',
      'terms': <Object?>[],
    });

    await tester.enterText(textField('Nome'), 'Música');
    await tester.pump();
    await tester.tap(find.text('Criar grupo'));
    await tester.pumpAndSettle();

    expect(find.text('Você já tem um grupo com esse nome.'), findsOneWidget);
    expect(find.byType(GroupModal), findsOneWidget);
  });

  testWidgets('editar: abre preenchido e aceita o próprio nome', (
    tester,
  ) async {
    await edit(tester);

    expect(find.text('Editar grupo'), findsOneWidget);
    expect(find.text('Viagem'), findsOneWidget);

    await tester.enterText(textField('Nome'), 'VIAGEM');
    await tester.pump();

    expect(find.text('Você já tem um grupo com esse nome.'), findsNothing);
    expect(button(tester, 'Salvar').onPressed, isNotNull);
  });

  testWidgets('editar: nome de outro grupo trava', (tester) async {
    await edit(tester);

    await tester.enterText(textField('Nome'), 'trabalho');
    await tester.pump();

    expect(find.text('Você já tem um grupo com esse nome.'), findsOneWidget);
    expect(button(tester, 'Salvar').onPressed, isNull);
  });

  testWidgets('editar: salva e fecha com o grupo atualizado', (tester) async {
    final (results, (:store, :api)) = await edit(tester);

    await tester.tap(find.bySemanticsLabel('Rosa'));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final body = api.bodies['PATCH /api/v1/groups/1']! as Map;
    expect((body['name'], body['accent']), ('Viagem', 'pink'));
    expect(results.single!.color, GroupColor.pink);
    expect(store.data!.groups.first.color, GroupColor.pink);
    expect(find.byType(GroupModal), findsNothing);
  });
}
