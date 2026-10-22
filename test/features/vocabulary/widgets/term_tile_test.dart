import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('termo aprendendo', (tester) async {
    await tester.pumpComponent(
      const TermTile(term: Term('jet lag', 'cansaço', TermKind.expression, 1)),
    );

    expect(find.text('jet lag'), findsOneWidget);
    expect(find.text('cansaço'), findsOneWidget);
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
      const TermTile(term: Term('layover', 'escala', TermKind.word, 5)),
    );

    expect(find.text('PALAVRA'), findsOneWidget);
    expect(find.text('Dominado'), findsOneWidget);
    expect(
      tester.widget<StatusPill>(find.byType(StatusPill)).tone,
      StatusTone.mastered,
    );
  });
}
