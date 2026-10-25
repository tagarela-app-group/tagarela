import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('toque chama onTap e lê o rótulo', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      HeaderPill(
        onTap: () => taps++,
        semanticLabel: 'Trocar curso',
        child: const Text('EN'),
      ),
    );

    await tester.tap(find.byType(HeaderPill));

    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(HeaderPill)),
      isSemantics(label: 'Trocar curso', isButton: true),
    );
  });

  testWidgets('sem onTap é só rótulo, em branco sobre o header', (
    tester,
  ) async {
    await tester.pumpComponent(
      const HeaderPill(height: 24, child: Text('Viagem')),
    );

    expect(find.byType(InkWell), findsNothing);
    expect(
      DefaultTextStyle.of(tester.element(find.text('Viagem'))).style.color,
      AppPalette.white,
    );
    expect(tester.getSize(find.byType(HeaderPill)).height, 24);
  });
}
