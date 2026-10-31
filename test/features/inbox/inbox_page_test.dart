import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/inbox_page.dart';
import 'package:tagarela/features/inbox/pick_terms_page.dart';
import 'package:tagarela/features/inbox/widgets/capture_card.dart';

import '../../helpers/fake_capture_api.dart';
import '../../helpers/fake_capture_store.dart';
import '../../helpers/l10n.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeCaptures captures;

  setUp(() => captures = fakeCaptures());

  Future<void> seed(List<Capture> items) async {
    for (final capture in items) {
      await captures.db.saveCapture('ana@example.com', capture);
    }
  }

  Future<void> seedAll() => seed([
    sampleCapture('falhou', status: CaptureStatus.failed),
    sampleCapture('pronta', text: 'Pronta pra escolher'),
    sampleCapture('processando', status: CaptureStatus.processing),
    sampleCapture(
      'esperando',
      text: 'Ainda não enviada',
      pending: const {CaptureSync.create},
    ),
    sampleCapture(
      'analisada',
      status: CaptureStatus.analyzed,
      text: 'Já analisada',
    ),
  ]);

  Future<void> pumpInbox(WidgetTester tester) async {
    await tester.pumpPage(
      const InboxPage(),
      deps: fakeDependencies(captures: captures.store),
    );
  }

  List<String> sectionLabels(WidgetTester tester) => [
    for (final text in tester.widgetList<Text>(find.byType(Text)))
      if (text.data case final data?
          when data.contains(' · ') && data == data.toUpperCase())
        data,
  ];

  testWidgets('sem capturas: Inbox zerado, sem abas', (tester) async {
    await pumpInbox(tester);

    expect(find.text('Inbox zerado'), findsOneWidget);
    expect(find.byType(SegmentedControl), findsNothing);
    expect(find.text('0 capturas'), findsOneWidget);
  });

  testWidgets('Todas: seções na ordem, sem as analisadas', (tester) async {
    await seedAll();
    await pumpInbox(tester);

    expect(sectionLabels(tester), [
      'PRECISA DE ATENÇÃO · 1',
      'PRONTAS · 2',
      'PROCESSANDO · 1',
    ]);
    expect(find.text('4 capturas · 1 esperando envio'), findsOneWidget);
    expect(find.text('Já analisada'), findsNothing);
    expect(find.text('Analisadas'), findsNothing);
  });

  testWidgets('abas filtram as seções', (tester) async {
    await seedAll();
    await pumpInbox(tester);

    await tester.tap(find.text('Prontas').first);
    await tester.pump();
    expect(sectionLabels(tester), ['PRONTAS · 2']);

    await tester.tap(find.text('Pendentes'));
    await tester.pump();
    expect(sectionLabels(tester), [
      'PRECISA DE ATENÇÃO · 1',
      'PROCESSANDO · 1',
    ]);
  });

  testWidgets('aba vazia avisa', (tester) async {
    await seed([sampleCapture('pronta')]);
    await pumpInbox(tester);

    await tester.tap(find.text('Pendentes'));
    await tester.pump();

    expect(find.text('Nada por aqui'), findsOneWidget);
    expect(find.byType(CaptureCard), findsNothing);
  });

  testWidgets('Descartar tira o card', (tester) async {
    await seed([sampleCapture('pronta')]);
    await pumpInbox(tester);

    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();

    expect(find.byType(CaptureCard), findsNothing);
    expect(find.text('Inbox zerado'), findsOneWidget);
  });

  testWidgets('Analisar tira o card do Inbox', (tester) async {
    await seed([
      sampleCapture(
        'pronta',
        terms: const [CaptureTerm(text: 'mind the gap', start: 7, end: 19)],
      ),
    ]);
    await pumpInbox(tester);

    await tester.tap(find.text('Analisar'));
    await tester.pumpAndSettle();

    expect(find.byType(CaptureCard), findsNothing);
    expect(find.text('Inbox zerado'), findsOneWidget);
  });

  testWidgets('Analisar com uma palavra só manda ela como termo', (
    tester,
  ) async {
    await seed([
      sampleCapture(
        'pronta',
        text: 'Gotcha!',
        pending: const {CaptureSync.create},
      ),
    ]);
    await pumpInbox(tester);

    await tester.tap(find.text('Analisar'));
    await tester.pumpAndSettle();

    final saved = await captures.db.capture('pronta');
    expect(saved!.terms.single.text, 'Gotcha');
    expect(saved.status, CaptureStatus.analyzed);
  });

  Future<void> pumpAnalyzable(
    WidgetTester tester,
    VoidCallback onSeeTerms,
  ) async {
    await seed([
      sampleCapture(
        'pronta',
        pending: const {CaptureSync.create},
        terms: const [CaptureTerm(text: 'mind the gap', start: 7, end: 19)],
      ),
    ]);
    await tester.pumpPage(
      Scaffold(body: InboxPage(onSeeTerms: onSeeTerms)),
      deps: fakeDependencies(captures: captures.store),
    );
    await tester.tap(find.text('Analisar'));
  }

  testWidgets('analisar avisa e Ver leva pros termos', (tester) async {
    var seen = 0;
    await pumpAnalyzable(tester, () => seen++);
    await tester.pumpUntilFound(find.text('1 termo no vocabulário'));

    expect(find.text('1 termo no vocabulário'), findsOneWidget);
    await tester.tap(find.text('Ver'));
    expect(seen, 1);
  });

  testWidgets('analisar sem internet avisa que sobe depois, sem Ver', (
    tester,
  ) async {
    captures.api.offline = true;
    await pumpAnalyzable(tester, () {});
    await tester.pumpUntilFound(find.text('Análise guardada'));

    expect(find.text('Análise guardada'), findsOneWidget);
    expect(find.text('Ver'), findsNothing);
  });

  testWidgets('escolher e confirmar na outra tela também avisa', (
    tester,
  ) async {
    await seed([
      sampleCapture(
        'pronta',
        text: 'gotcha',
        pending: const {CaptureSync.create},
      ),
    ]);
    await tester.pumpPage(
      const Scaffold(body: InboxPage()),
      deps: fakeDependencies(captures: captures.store),
    );

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(find.byType(TermChip), findsOneWidget);
    await tester.tap(find.textContaining('Confirmar análise'));
    await tester.pumpUntilFound(find.text('1 termo no vocabulário'));

    expect(find.text('1 termo no vocabulário'), findsOneWidget);
  });

  testWidgets('Escolher abre a tela da captura', (tester) async {
    await seed([sampleCapture('pronta', text: 'Pronta pra escolher')]);
    await pumpInbox(tester);

    await tester.tap(find.text('Escolher'));
    await tester.pumpAndSettle();

    expect(find.byType(PickTermsPage), findsOneWidget);
    expect(find.text('escolher'), findsOneWidget);
  });

  testWidgets('puxar a lista sincroniza com a API', (tester) async {
    await pumpInbox(tester);
    await captures.api.post(FakeCaptureApi.path, {
      'id': 'outro-aparelho',
      'source': 'text',
      'captured_at': '2026-10-23T10:00:00Z',
      'text': 'Vinda de outro aparelho',
    });

    await tester.fling(find.byType(Scrollable), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('“vinda de outro aparelho”'), findsOneWidget);
  });

  test('resumo do topo', () {
    expect(summary(pt, []), '0 capturas');
    expect(summary(pt, [sampleCapture('a')]), '1 captura');
    expect(
      summary(pt, [
        sampleCapture('a'),
        sampleCapture('b', pending: const {CaptureSync.update}),
      ]),
      '2 capturas · 1 esperando envio',
    );
  });
}
