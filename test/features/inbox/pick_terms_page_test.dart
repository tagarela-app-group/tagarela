import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/pick_terms_page.dart';

import '../../helpers/fake_capture_api.dart';
import '../../helpers/fake_capture_store.dart';
import '../../helpers/pump_app.dart';

void main() {
  const text = 'Please mind the gap between the train and the platform.';
  late FakeCaptures captures;

  setUp(() => captures = fakeCaptures());

  Capture only() => captures.store.data!.single;

  Future<Capture> open(WidgetTester tester, {Capture? capture}) async {
    final opened = capture ?? await captures.store.createText(text);
    if (capture != null) {
      await captures.db.saveCapture('ana@example.com', capture);
    }
    await tester.pumpPage(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PickTermsPage(capture: opened),
              ),
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
      captures: captures.store,
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    return opened;
  }

  List<String> chips(WidgetTester tester) => [
    for (final chip in tester.widgetList<TermChip>(find.byType(TermChip)))
      chip.label,
  ];

  AppButton confirmButton(WidgetTester tester) => tester.widget<AppButton>(
    find.byWidgetPredicate(
      (w) => w is AppButton && w.size == AppButtonSize.large,
    ),
  );

  testWidgets('abre com o texto e sem termo escolhido', (tester) async {
    await open(tester);

    expect(find.text('Escolher termos'), findsOneWidget);
    expect(find.textContaining('Texto · '), findsOneWidget);
    expect(find.text('gap'), findsOneWidget);
    expect(find.text('TERMOS ESCOLHIDOS · 0'), findsOneWidget);
    expect(
      find.text('Nenhum ainda. Toque numa palavra do texto.'),
      findsOneWidget,
    );
    expect(confirmButton(tester).label, 'Escolha pelo menos um termo');
    expect(confirmButton(tester).onPressed, isNull);
  });

  testWidgets('toque marca a palavra e o X tira', (tester) async {
    await open(tester);

    await tester.tap(find.text('gap'));
    await tester.pump();

    expect(chips(tester), ['gap']);
    expect(confirmButton(tester).label, 'Confirmar análise · 1 termo');

    await tester.tap(find.byTooltip('Remover gap'));
    await tester.pump();

    expect(chips(tester), isEmpty);
  });

  testWidgets('arrastar marca a expressão, toque marca palavra dentro', (
    tester,
  ) async {
    await open(tester);
    final from = tester.getCenter(find.text('mind'));

    await tester.dragFrom(from, tester.getCenter(find.text('gap')) - from);
    await tester.pump();
    await tester.tap(find.text('mind'));
    await tester.pump();

    expect(chips(tester), ['mind the gap', 'mind']);
    expect(confirmButton(tester).label, 'Confirmar análise · 2 termos');
  });

  testWidgets('editar o texto mantém o termo que não mudou', (tester) async {
    await open(tester);
    await tester.tap(find.text('mind'));
    await tester.tap(find.text('gap'));
    await tester.pump();

    await tester.tap(find.text('Editar texto'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField),
      'Please mind the gaps between the train and the platform.',
    );
    await tester.tap(find.text('Pronto'));
    await tester.pump();

    expect(find.text('gaps'), findsOneWidget);
    expect(chips(tester), ['mind']);
  });

  testWidgets('texto apagado volta ao anterior', (tester) async {
    await open(tester);

    await tester.tap(find.text('Editar texto'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Pronto'));
    await tester.pump();

    expect(find.text('platform.'), findsOneWidget);
  });

  testWidgets('Confirmar análise salva texto e termos e volta', (tester) async {
    final capture = await open(tester);
    await tester.tap(find.text('mind'));
    await tester.pump();

    await tester.tap(find.text('Confirmar análise · 1 termo'));
    await tester.pumpAndSettle();

    expect(find.byType(PickTermsPage), findsNothing);
    expect(only().status, CaptureStatus.analyzed);
    expect(only().terms, const [CaptureTerm(text: 'mind', start: 7, end: 11)]);
    expect(only().pending, isEmpty);
    expect(captures.api.bodies['PATCH ${FakeCaptureApi.path}/${capture.id}'], {
      'text': text,
      'terms': [
        {'text': 'mind', 'start': 7, 'end': 11},
      ],
    });
  });

  testWidgets('Voltar descarta o que foi marcado', (tester) async {
    await open(tester);
    await tester.tap(find.text('mind'));
    await tester.pump();

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.byType(PickTermsPage), findsNothing);
    expect(only().status, CaptureStatus.ready);
    expect(only().terms, isEmpty);
  });

  testWidgets('lixeira descarta a captura e volta', (tester) async {
    await open(tester);

    await tester.tap(find.byTooltip('Descartar captura'));
    await tester.pumpAndSettle();

    expect(find.byType(PickTermsPage), findsNothing);
    expect(captures.store.data, isEmpty);
  });

  testWidgets('abre com os termos que a captura já tem', (tester) async {
    await open(
      tester,
      capture: sampleCapture(
        'pronta',
        terms: const [CaptureTerm(text: 'mind the gap', start: 7, end: 19)],
      ),
    );

    expect(chips(tester), ['mind the gap']);
  });

  testWidgets('expressão grande demais avisa e não marca', (tester) async {
    await open(
      tester,
      capture: sampleCapture(
        'longa',
        text: '${List.filled(30, 'word').join(' ')} end',
      ),
    );
    final from =
        tester.getTopLeft(find.text('word').first) + const Offset(4, 4);

    await tester.dragFrom(from, tester.getCenter(find.text('end')) - from);
    await tester.pump();

    expect(
      find.text('Expressão grande demais. Marque até 100 caracteres.'),
      findsOneWidget,
    );
    expect(chips(tester), isEmpty);
  });
}
