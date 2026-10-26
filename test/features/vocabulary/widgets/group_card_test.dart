import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/widgets/group_card.dart';

import '../../../helpers/pump_app.dart';

TermGroup _group(List<int> levels) => TermGroup(
  id: '1',
  name: 'Comida',
  icon: AppIcons.travel,
  accent: AppAccent.mint,
  terms: [for (final l in levels) Term('t$l', 't', 't', TermKind.word, l)],
);

void main() {
  testWidgets('mostra nome, total e % dominado arredondado pra baixo', (
    tester,
  ) async {
    await tester.pumpComponent(
      GroupCard(group: _group([4, 5, 1]), onTap: () {}),
    );

    expect(find.text('Comida'), findsOneWidget);
    expect(find.text('3 termos'), findsOneWidget);
    expect(find.text('66% dominado'), findsOneWidget);
  });

  testWidgets('grupo vazio = 0% sem dividir por zero', (tester) async {
    await tester.pumpComponent(GroupCard(group: _group([]), onTap: () {}));

    expect(find.text('Sem termos ainda'), findsOneWidget);
    expect(find.text('0% dominado'), findsOneWidget);
  });

  testWidgets('chama onTap no toque', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      GroupCard(group: _group([1]), onTap: () => taps++),
    );

    await tester.tap(find.text('Comida'));
    expect(taps, 1);
  });
}
