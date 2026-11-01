import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('anel preenche `level` de `max` e mostra o número', (
    tester,
  ) async {
    await tester.pumpComponent(
      const LevelRing(level: 3, color: AppPalette.mint),
    );

    final ring = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(ring.value, 3 / 5);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('acessibilidade lê o nível, não a porcentagem', (tester) async {
    await tester.pumpComponent(
      const LevelRing(level: 2, color: AppPalette.mint),
    );

    expect(find.bySemanticsLabel('Nível 2 de 5'), findsOneWidget);
  });
}
