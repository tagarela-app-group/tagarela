import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('vidro com o conteúdo e largura máxima', (tester) async {
    await tester.pumpComponent(
      const Center(
        child: GlassPanel(maxWidth: 200, child: Text('O que será que é?')),
      ),
    );

    expect(find.text('O que será que é?'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(
      tester.getSize(find.byType(GlassPanel)).width,
      lessThanOrEqualTo(200),
    );
  });
}
