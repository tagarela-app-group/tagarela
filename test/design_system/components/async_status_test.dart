import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('sem erro = carregando', (tester) async {
    await tester.pumpComponent(AsyncStatus(error: null, onRetry: () {}));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
    expect(find.byType(StateMessage), findsNothing);
  });

  testWidgets('com erro mostra mensagem e tenta de novo', (tester) async {
    var retries = 0;
    await tester.pumpComponent(
      AsyncStatus(error: Exception('rede'), onRetry: () => retries++),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Não deu pra carregar'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    expect(retries, 1);
  });
}
