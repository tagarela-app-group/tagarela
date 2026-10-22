import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/features/inbox/inbox_page.dart';
import 'package:tagarela/features/inbox/widgets/inbox_item_card.dart';

import '../../helpers/fake_api_client.dart';
import '../../helpers/pump_app.dart';

List<InboxItem> _ready(AppScope scope) =>
    scope.inbox.data!.where((i) => i.status == InboxStatus.ready).toList();

void main() {
  testWidgets('separa itens prontos e em análise', (tester) async {
    final scope = await tester.pumpPage(const InboxPage());

    final items = scope.inbox.data!;
    final ready = _ready(scope).length;
    expect(
      find.text('${items.length} termos aguardando análise'),
      findsOneWidget,
    );
    expect(find.text('PRONTOS PARA REVISAR · $ready'), findsOneWidget);
    expect(find.text('EM ANÁLISE · ${items.length - ready}'), findsOneWidget);
    expect(find.byType(InboxItemCard), findsNWidgets(items.length));
  });

  testWidgets('"Adicionar" remove o item e avisa o grupo', (tester) async {
    final scope = await tester.pumpPage(const InboxPage());
    final first = _ready(scope).first;
    final count = scope.inbox.data!.length;

    await tester.tap(find.text('Adicionar').first);
    await tester.pump();

    expect(find.text(first.content), findsNothing);
    expect(
      find.text('Adicionado em ${first.suggestion!.groupName}'),
      findsOneWidget,
    );
    expect(find.text('${count - 1} termos aguardando análise'), findsOneWidget);
  });

  testWidgets('"Descartar" remove o item sem aviso', (tester) async {
    final scope = await tester.pumpPage(const InboxPage());
    final first = _ready(scope).first;

    await tester.tap(find.text('Descartar').first);
    await tester.pump();

    expect(find.text(first.content), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('falha ao salvar mantém o item e avisa', (tester) async {
    final api = FakeApiClient();
    final scope = await tester.pumpPage(const InboxPage(), api: api);
    final first = _ready(scope).first;

    api.failing = true;
    await tester.tap(find.text('Adicionar').first);
    await tester.pump();

    expect(find.text(first.content), findsOneWidget);
    expect(find.text('Não deu pra salvar. Tente de novo.'), findsOneWidget);
  });

  testWidgets('sem itens prontos some a seção de revisão', (tester) async {
    final scope = await tester.pumpPage(const InboxPage());

    for (var i = _ready(scope).length; i > 0; i--) {
      await tester.tap(find.text('Descartar').first);
      await tester.pump();
    }

    expect(find.textContaining('PRONTOS PARA REVISAR'), findsNothing);
    expect(find.textContaining('EM ANÁLISE'), findsOneWidget);
  });

  testWidgets('Inbox vazio mostra estado zerado', (tester) async {
    final api = FakeApiClient()..db['inbox'] = [];
    await tester.pumpPage(const InboxPage(), api: api);

    expect(find.text('Inbox zerado'), findsOneWidget);
    expect(find.byType(InboxItemCard), findsNothing);
  });

  testWidgets('carregando mostra spinner', (tester) async {
    await tester.pumpPage(const InboxPage(), load: false);

    expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
  });
}
