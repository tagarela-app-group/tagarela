import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('toque chama a ação e a acessibilidade lê como botão', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpComponent(
      PillButton(
        label: 'Agrupar',
        icon: AppIcons.newGroup,
        onPressed: () => taps++,
      ),
    );

    await tester.tap(find.text('Agrupar'));

    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(PillButton)),
      containsSemantics(label: 'Agrupar', isButton: true, hasTapAction: true),
    );
  });
}
