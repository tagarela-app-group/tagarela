import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra rótulo e chama onPressed no toque', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      AppButton(label: 'Entrar', onPressed: () => taps++),
    );

    await tester.tap(find.text('Entrar'));
    expect(taps, 1);
  });

  testWidgets('onPressed nulo desabilita o botão', (tester) async {
    await tester.pumpComponent(
      const AppButton(label: 'Entrar', onPressed: null),
    );

    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.enabled, isFalse);
  });

  testWidgets('loading troca o leading por spinner e ignora toque', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpComponent(
      AppButton(
        label: 'Google',
        onPressed: () => taps++,
        leading: const Icon(AppIcons.add),
        loading: true,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(AppIcons.add), findsNothing);
    expect(find.text('Google'), findsOneWidget);

    await tester.tap(find.text('Google'), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('rótulo longo em espaço estreito corta em vez de estourar', (
    tester,
  ) async {
    await tester.pumpComponent(
      Center(
        child: SizedBox(
          width: 156,
          child: AppButton(
            label: 'Salvar no Inbox',
            onPressed: () {},
            loading: true,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('loading sem onPressed mantém a cor da variante', (tester) async {
    await tester.pumpComponent(
      const AppButton(label: 'Entrar', onPressed: null, loading: true),
    );

    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.enabled, isTrue);
  });
}
