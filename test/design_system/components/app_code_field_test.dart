import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra cada dígito na sua caixa', (tester) async {
    final controller = TextEditingController();
    await tester.pumpComponent(AppCodeField(controller: controller));

    await tester.enterText(find.byType(TextField), '482');
    await tester.pump();

    for (final digit in ['4', '8', '2']) {
      expect(find.text(digit), findsOneWidget);
    }
  });

  testWidgets('aceita só dígitos e no máximo o tamanho', (tester) async {
    final controller = TextEditingController();
    await tester.pumpComponent(AppCodeField(controller: controller));

    await tester.enterText(find.byType(TextField), '12a3456789');

    expect(controller.text, '123456');
  });

  testWidgets('avisa quando completa o código', (tester) async {
    String? completed;
    await tester.pumpComponent(
      AppCodeField(
        controller: TextEditingController(),
        length: 4,
        onCompleted: (code) => completed = code,
      ),
    );

    await tester.enterText(find.byType(TextField), '123');
    expect(completed, isNull);
    await tester.enterText(find.byType(TextField), '1234');
    expect(completed, '1234');
  });

  testWidgets('mostra errorText e rótulo de acessibilidade', (tester) async {
    await tester.pumpComponent(
      AppCodeField(
        controller: TextEditingController(),
        errorText: 'Código incorreto.',
      ),
    );

    expect(find.text('Código incorreto.'), findsOneWidget);
    expect(find.bySemanticsLabel('Código de 6 dígitos'), findsOneWidget);
  });
}
