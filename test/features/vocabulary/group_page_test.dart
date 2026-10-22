import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';

import '../../helpers/pump_app.dart';

const _group = TermGroup(
  id: '1',
  name: 'Viagem',
  icon: AppIcons.travel,
  accent: AppAccent.sky,
  terms: [
    Term('layover', 'escala', TermKind.word, 4),
    Term('carry-on', 'bagagem de mão', TermKind.word, 2),
    Term('jet lag', 'cansaço do fuso', TermKind.expression, 1),
  ],
);

Finder _option(String label) => find.descendant(
  of: find.byType(SegmentedControl),
  matching: find.text(label),
);

List<String> _shownTerms(WidgetTester tester) => tester
    .widgetList<TermTile>(find.byType(TermTile))
    .map((t) => t.term.text)
    .toList();

void main() {
  testWidgets('header resume o grupo', (tester) async {
    await tester.pumpPage(const GroupPage(group: _group));

    expect(find.text('Viagem'), findsOneWidget);
    expect(find.text('3 termos · 1 dominados'), findsOneWidget);
    expect(find.bySemanticsLabel('2 aprendendo, 1 dominados'), findsOneWidget);
  });

  testWidgets('filtro começa em todos', (tester) async {
    await tester.pumpPage(const GroupPage(group: _group));

    expect(find.text('Todos · 3'), findsOneWidget);
    expect(_shownTerms(tester), ['layover', 'carry-on', 'jet lag']);
  });

  testWidgets('filtra por aprendendo e dominado', (tester) async {
    await tester.pumpPage(const GroupPage(group: _group));

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
    await tester.pumpPage(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GroupPage(group: _group)),
          ),
          child: const Text('Abrir'),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupPage), findsNothing);
  });
}
