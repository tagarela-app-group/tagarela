import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('expõe estado selecionado na acessibilidade', (tester) async {
    await tester.pumpComponent(
      AppChip(label: 'Todos', selected: true, onTap: () {}),
    );

    expect(
      tester.getSemantics(find.text('Todos')),
      isSemantics(isButton: true, isSelected: true, hasTapAction: true),
    );
  });
}
