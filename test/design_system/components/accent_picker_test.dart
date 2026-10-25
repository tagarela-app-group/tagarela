import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/l10n.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('uma bolinha por cor; a escolhida tem o check', (tester) async {
    final picked = <AppAccent>[];
    await tester.pumpComponent(
      AccentPicker(selected: AppAccent.mint, onChanged: picked.add),
    );

    expect(find.text('Cor'), findsOneWidget);
    for (final accent in AppAccent.values) {
      expect(find.bySemanticsLabel(pt.accentName(accent.name)), findsOneWidget);
    }
    expect(find.byIcon(AppIcons.check), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Rosa'));
    expect(picked, [AppAccent.pink]);
  });

  testWidgets('cores em linhas de seis', (tester) async {
    await tester.pumpComponent(
      AccentPicker(selected: AppAccent.violet, onChanged: (_) {}),
    );

    final rows = AppAccent.values.length ~/ AccentPicker.columns;
    expect(rows, 2);
    final tops = {
      for (final accent in AppAccent.values)
        tester.getTopLeft(find.bySemanticsLabel(pt.accentName(accent.name))).dy,
    };
    expect(tops, hasLength(rows));
    expect(
      tester.getTopLeft(find.bySemanticsLabel('Uva')).dy,
      greaterThan(tester.getTopLeft(find.bySemanticsLabel('Violeta')).dy),
    );
  });
}
