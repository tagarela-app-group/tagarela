import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('termo aprendendo, sem a tradução que a ficha esconde', (
    tester,
  ) async {
    await tester.pumpComponent(
      const TermTile(term: Term('t1', 'jet lag', TermKind.expression, 1)),
    );

    expect(find.text('jet lag'), findsOneWidget);
    expect(find.text('cansaço'), findsNothing);
    expect(find.text('Expressão · Aprendendo'), findsOneWidget);
    final ring = tester.widget<LevelRing>(find.byType(LevelRing));
    expect(ring.level, 1);
    expect(ring.color, AppColors.light.learning);
  });

  testWidgets('termo dominado', (tester) async {
    await tester.pumpComponent(
      const TermTile(term: Term('t2', 'layover', TermKind.word, 5)),
    );

    expect(find.text('Palavra · Dominado'), findsOneWidget);
    expect(
      tester.widget<LevelRing>(find.byType(LevelRing)).color,
      AppColors.light.mastered,
    );
  });

  testWidgets('sem tradução: some a linha', (tester) async {
    await tester.pumpComponent(
      const TermTile(term: Term('t3', 'touch base', TermKind.expression, 0)),
    );

    expect(find.text('touch base'), findsOneWidget);
    expect(find.text(''), findsNothing);
  });

  testWidgets('selecionando: caixa marcada, borda e toque', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      TermTile(
        term: const Term('t1', 'jet lag', TermKind.expression, 1),
        selecting: true,
        selected: true,
        onTap: () => taps++,
      ),
    );

    expect(
      tester.widget<AppCheckbox>(find.byType(AppCheckbox)).checked,
      isTrue,
    );
    expect(tester.widget<AppCard>(find.byType(AppCard)).selected, isTrue);
    expect(find.byType(LevelRing), findsNothing);

    await tester.tap(find.text('jet lag'));
    expect(taps, 1);
  });

  group('grupo', () {
    const term = Term('t1', 'jet lag', TermKind.expression, 1);

    testWidgets('sem grupo: Agrupar chama a ação sem abrir o termo', (
      tester,
    ) async {
      var added = 0;
      var opened = 0;
      await tester.pumpComponent(
        TermTile(
          term: term,
          showGroup: true,
          onAddToGroup: () => added++,
          onTap: () => opened++,
        ),
      );

      await tester.tap(find.text('Agrupar'));

      expect(added, 1);
      expect(opened, 0);
    });

    testWidgets('com grupo: mostra o nome no lugar de Agrupar', (tester) async {
      await tester.pumpComponent(
        const TermTile(
          term: term,
          showGroup: true,
          group: TermGroup(
            id: 'g1',
            name: 'Viagem',
            icon: GroupIcon.travel,
            color: GroupColor.mint,
            terms: [],
          ),
        ),
      );

      expect(find.text('Viagem'), findsOneWidget);
      expect(find.text('Agrupar'), findsNothing);
    });

    testWidgets('selecionando: Agrupar some', (tester) async {
      await tester.pumpComponent(
        const TermTile(term: term, showGroup: true, selecting: true),
      );

      expect(find.text('Agrupar'), findsNothing);
    });

    testWidgets('dentro do grupo: sem Agrupar', (tester) async {
      await tester.pumpComponent(const TermTile(term: term));

      expect(find.text('Agrupar'), findsNothing);
    });
  });

  testWidgets('fora da seleção: sem caixa', (tester) async {
    await tester.pumpComponent(
      const TermTile(term: Term('t1', 'jet lag', TermKind.expression, 1)),
    );

    expect(find.byType(AppCheckbox), findsNothing);
  });
}
