import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/features/inbox/widgets/audio_clip.dart';
import 'package:tagarela/features/inbox/widgets/capture_card.dart';

import '../../../helpers/fake_capture_store.dart';
import '../../../helpers/fake_extraction.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeCaptures captures;
  final now = DateTime(2026, 10, 23, 12);
  const terms = [
    CaptureTerm(text: 'mind the gap', start: 7, end: 19),
    CaptureTerm(text: 'mind', start: 7, end: 11),
  ];

  setUp(() => captures = fakeCaptures());

  Future<List<String>> pumpCard(
    WidgetTester tester,
    Capture capture, {
    bool withMedia = true,
    bool canPick = false,
    SpeechModelStore? speech,
  }) async {
    final path = capture.mediaPath;
    if (withMedia && path != null) captures.media.files[path] = File(path);
    final taps = <String>[];
    await tester.pumpPage(
      SingleChildScrollView(
        child: CaptureCard(
          capture: capture,
          now: now,
          onDiscard: () => taps.add('descartar'),
          onProcess: () => taps.add('processar'),
          onPick: canPick ? () => taps.add('escolher') : null,
          onConfirm: () => taps.add('confirmar'),
        ),
      ),
      captures: captures.store,
      speech: speech,
    );
    await tester.pump();
    return taps;
  }

  Capture photo(CaptureStatus status) => sampleCapture(
    'p1',
    source: CaptureSource.photo,
    status: status,
    mediaPath: 'captures/photo/p1.jpg',
  );

  Capture audio(CaptureStatus status) => sampleCapture(
    'a1',
    source: CaptureSource.audio,
    status: status,
    mediaPath: 'captures/audio/a1.m4a',
  );

  group('timeAgo', () {
    test('minutos, horas, ontem e data', () {
      expect(timeAgo(now.subtract(const Duration(seconds: 30)), now), 'agora');
      expect(
        timeAgo(now.subtract(const Duration(minutes: 5)), now),
        'há 5 min',
      );
      expect(timeAgo(now.subtract(const Duration(hours: 2)), now), 'há 2 h');
      expect(timeAgo(DateTime(2026, 10, 22, 23), now), 'ontem');
      expect(timeAgo(DateTime(2026, 10, 3, 8), now), '03/10');
    });
  });

  testWidgets('erro: aviso, Descartar e Processar agora', (tester) async {
    final taps = await pumpCard(tester, photo(CaptureStatus.failed));

    expect(find.text('Erro'), findsOneWidget);
    expect(find.text('Foto · há 3 h'), findsOneWidget);
    expect(find.text('Não deu pra processar agora'), findsOneWidget);
    expect(
      find.text('Toque em Processar agora pra tentar de novo.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Foto da captura'), findsOneWidget);

    await tester.tap(find.text('Descartar'));
    await tester.tap(find.text('Processar agora'));
    expect(taps, ['descartar', 'processar']);
  });

  testWidgets('áudio esperando o modelo: avisa e troca quando fica pronto', (
    tester,
  ) async {
    final speech = fakeSpeechModel();
    speech.storage.hold = Completer();
    await pumpCard(
      tester,
      audio(
        CaptureStatus.processing,
      ).copyWith(pending: const {CaptureSync.extract, CaptureSync.create}),
      speech: speech.store,
    );

    expect(find.text('Esperando o modelo de áudio baixar…'), findsOneWidget);

    speech.storage.hold!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Transcrevendo o áudio…'), findsOneWidget);
  });

  testWidgets('erro sem texto: foto e áudio', (tester) async {
    await pumpCard(
      tester,
      sampleCapture(
        'p1',
        source: CaptureSource.photo,
        status: CaptureStatus.failed,
        mediaPath: 'captures/photo/p1.jpg',
        error: 'no_text',
      ),
    );
    expect(find.text('Não achei texto na foto'), findsOneWidget);
    expect(find.text('Tente outra foto ou descarte esta.'), findsOneWidget);

    await pumpCard(
      tester,
      sampleCapture(
        'a1',
        source: CaptureSource.audio,
        status: CaptureStatus.failed,
        error: 'no_text',
      ),
    );
    expect(find.text('Não ouvi fala em inglês'), findsOneWidget);
    expect(find.text('Grave de novo ou descarte este áudio.'), findsOneWidget);
  });

  testWidgets('pronta sem termos: Escolher termos só com destino', (
    tester,
  ) async {
    await pumpCard(tester, sampleCapture('t1'));

    expect(find.text('Pronta'), findsOneWidget);
    expect(find.text('Seu texto'), findsOneWidget);
    expect(find.text('Escolher termos'), findsNothing);
    expect(find.text('Descartar'), findsOneWidget);
  });

  testWidgets('pronta sem termos com destino: Escolher termos', (tester) async {
    final taps = await pumpCard(tester, sampleCapture('t1'), canPick: true);

    await tester.tap(find.text('Escolher termos'));
    expect(taps, ['escolher']);
  });

  testWidgets('pronta com termos: chips, Editar e Confirmar análise', (
    tester,
  ) async {
    final taps = await pumpCard(
      tester,
      sampleCapture('t1', terms: terms),
      canPick: true,
    );

    expect(find.text('2 termos escolhidos'), findsOneWidget);
    expect(find.text('mind the gap'), findsOneWidget);
    expect(find.text('Descartar'), findsNothing);

    await tester.tap(find.text('Editar'));
    await tester.tap(find.text('Confirmar análise'));
    expect(taps, ['escolher', 'confirmar']);
  });

  testWidgets('pronta de foto que sumiu do celular avisa', (tester) async {
    await pumpCard(tester, photo(CaptureStatus.ready), withMedia: false);

    expect(find.text('Texto da foto'), findsOneWidget);
    expect(
      find.text('A foto não está mais neste celular. O texto continua salvo.'),
      findsOneWidget,
    );
  });

  testWidgets('pronta de áudio: transcrição, sem player', (tester) async {
    await pumpCard(tester, audio(CaptureStatus.ready));

    expect(find.text('Transcrição'), findsOneWidget);
    expect(find.byType(AudioClip), findsNothing);
    expect(find.textContaining('não está mais neste celular'), findsNothing);
  });

  testWidgets('áudio processando: player e aviso', (tester) async {
    await pumpCard(tester, audio(CaptureStatus.processing));

    expect(find.text('Processando'), findsOneWidget);
    expect(find.byType(AudioClip), findsOneWidget);
    expect(find.text('Transcrevendo o áudio…'), findsOneWidget);
  });

  testWidgets('foto processando lê o texto', (tester) async {
    await pumpCard(tester, photo(CaptureStatus.processing));

    expect(find.text('Lendo o texto da foto…'), findsOneWidget);
  });
}
