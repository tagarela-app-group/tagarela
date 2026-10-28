import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/capture/modals/text_capture_modal.dart';

import '../../../helpers/fake_capture_store.dart';
import '../../../helpers/open_modal.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeCaptures captures;

  setUp(() => captures = fakeCaptures());

  testWidgets('abre focado, contador em 0/500 e Salvar desligado', (
    tester,
  ) async {
    await tester.openModal(
      const TextCaptureModal(),
      deps: fakeDependencies(captures: captures.store),
    );

    expect(find.text('Digitar texto'), findsOneWidget);
    expect(find.text('Palavra, expressão ou frase'), findsOneWidget);
    expect(find.text('0/500'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
    expect(button(tester, 'Salvar no Inbox').onPressed, isNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(button(tester, 'Salvar no Inbox').onPressed, isNull);
  });

  testWidgets('para em 500 caracteres', (tester) async {
    await tester.openModal(
      const TextCaptureModal(),
      deps: fakeDependencies(captures: captures.store),
    );

    await tester.enterText(find.byType(TextField), 'a' * 600);
    await tester.pump();

    expect(find.text('500/500'), findsOneWidget);
  });

  testWidgets('Salvar no Inbox cria a captura e fecha', (tester) async {
    final results = await tester.openModal(
      const TextCaptureModal(),
      deps: fakeDependencies(captures: captures.store),
    );

    await tester.enterText(find.byType(TextField), "  I'm on the fence  ");
    await tester.pump();
    await tester.tap(find.text('Salvar no Inbox'));
    await tester.pumpAndSettle();

    expect(find.byType(AppModal), findsNothing);
    final saved = results.single!;
    expect(saved.source, CaptureSource.text);
    expect(saved.text, "I'm on the fence");
    expect(saved.pending, isEmpty);
    expect(captures.store.data!.single.id, saved.id);
  });

  testWidgets('fechar não salva', (tester) async {
    final results = await tester.openModal(
      const TextCaptureModal(),
      deps: fakeDependencies(captures: captures.store),
    );

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    expect(results, [null]);
    expect(captures.store.data, isEmpty);
  });
}
