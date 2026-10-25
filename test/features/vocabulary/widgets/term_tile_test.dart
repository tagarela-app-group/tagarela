import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('termo aprendendo, sem a tradução que a ficha esconde', (
    tester,
  ) async {
    await tester.pumpComponent(
      const TermTile(
        term: Term('t1', 'jet lag', 'cansaço', TermKind.expression, 1),
      ),
    );

    expect(find.text('jet lag'), findsOneWidget);
    expect(find.text('cansaço'), findsNothing);
    expect(find.text('EXPRESSÃO'), findsOneWidget);
    expect(find.text('Aprendendo'), findsOneWidget);
    expect(
      tester.widget<StatusPill>(find.byType(StatusPill)).tone,
      StatusTone.learning,
    );
    expect(tester.widget<LevelDots>(find.byType(LevelDots)).level, 1);
  });

  testWidgets('termo dominado', (tester) async {
    await tester.pumpComponent(
      const TermTile(term: Term('t2', 'layover', 'escala', TermKind.word, 5)),
    );

    expect(find.text('PALAVRA'), findsOneWidget);
    expect(find.text('Dominado'), findsOneWidget);
    expect(
      tester.widget<StatusPill>(find.byType(StatusPill)).tone,
      StatusTone.mastered,
    );
  });

  testWidgets('sem tradução: some a linha', (tester) async {
    await tester.pumpComponent(
      const TermTile(
        term: Term('t3', 'touch base', '', TermKind.expression, 0),
      ),
    );

    expect(find.text('touch base'), findsOneWidget);
    expect(find.text(''), findsNothing);
  });

  testWidgets('selecionando: caixa marcada, borda e toque', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      TermTile(
        term: const Term('t1', 'jet lag', 'cansaço', TermKind.expression, 1),
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

    await tester.tap(find.text('jet lag'));
    expect(taps, 1);
  });

  testWidgets('fora da seleção: sem caixa', (tester) async {
    await tester.pumpComponent(
      const TermTile(
        term: Term('t1', 'jet lag', 'cansaço', TermKind.expression, 1),
      ),
    );

    expect(find.byType(AppCheckbox), findsNothing);
  });
}
