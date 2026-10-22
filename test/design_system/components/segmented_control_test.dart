import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('toque devolve o índice da opção', (tester) async {
    int? changed;
    await tester.pumpComponent(
      SegmentedControl(
        options: const ['Todos', 'Aprendendo', 'Dominado'],
        selected: 0,
        onChanged: (i) => changed = i,
      ),
    );

    await tester.tap(find.text('Dominado'));
    expect(changed, 2);
  });

  testWidgets('marca só a opção selecionada', (tester) async {
    await tester.pumpComponent(
      SegmentedControl(
        options: const ['A', 'B'],
        selected: 1,
        onChanged: (_) {},
      ),
    );

    expect(
      tester.getSemantics(find.text('A')),
      isSemantics(isButton: true, isSelected: false),
    );
    expect(
      tester.getSemantics(find.text('B')),
      isSemantics(isButton: true, isSelected: true),
    );
  });
}
