import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('uma bolinha por cor; a escolhida tem o check', (tester) async {
    final picked = <AppAccent>[];
    await tester.pumpComponent(
      AccentPicker(selected: AppAccent.mint, onChanged: picked.add),
    );

    expect(find.text('Cor'), findsOneWidget);
    for (final name in AccentPicker.names.values) {
      expect(find.bySemanticsLabel(name), findsOneWidget);
    }
    expect(find.byIcon(AppIcons.check), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Rosa'));
    expect(picked, [AppAccent.pink]);
  });
}
