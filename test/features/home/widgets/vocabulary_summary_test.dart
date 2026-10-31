import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/home/widgets/vocabulary_summary.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra total e cada status', (tester) async {
    await tester.pumpComponent(
      VocabularySummary(learning: 30, mastered: 12, onSeeAll: () {}),
    );

    expect(find.text('42'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(
      find.bySemanticsLabel('30 aprendendo, 12 dominados'),
      findsOneWidget,
    );
  });

  testWidgets('"Ver tudo" chama onSeeAll', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      VocabularySummary(learning: 1, mastered: 1, onSeeAll: () => taps++),
    );

    await tester.tap(find.text('Ver tudo'));
    expect(taps, 1);
  });
}
