import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra rótulo em caixa alta', (tester) async {
    await tester.pumpComponent(const AppTag(label: 'Expressão'));

    expect(find.text('EXPRESSÃO'), findsOneWidget);
  });

  testWidgets('no header fica branca', (tester) async {
    await tester.pumpComponent(const AppTag(label: 'Palavra', onHeader: true));

    expect(
      tester.widget<Text>(find.text('PALAVRA')).style!.color,
      AppPalette.white,
    );
  });
}
