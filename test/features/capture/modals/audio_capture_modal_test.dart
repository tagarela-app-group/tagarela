import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/capture/modals/audio_capture_modal.dart';
import 'package:tagarela/shared/widgets/audio_clip.dart';

import '../../../helpers/fake_capture_store.dart';
import '../../../helpers/open_modal.dart';

void main() {
  late FakeCaptures captures;
  late FakeCaptureDevice device;
  late FakeAudioPlayback playback;

  setUp(() {
    captures = fakeCaptures();
    device = FakeCaptureDevice();
    playback = FakeAudioPlayback();
  });

  Future<List<Capture?>> open(WidgetTester tester) => tester.openModal(
    const AudioCaptureModal(),
    captures: captures.store,
    device: device,
    playback: playback,
  );

  Future<void> stop(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Parar gravação'));
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('abre gravando e conta o tempo', (tester) async {
    await open(tester);

    expect(device.recording, isTrue);
    expect(find.text('Gravando…'), findsOneWidget);
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('de 1:00'), findsOneWidget);
    expect(find.text('Toque para parar'), findsOneWidget);

    await tester.pump(const Duration(seconds: 12));

    expect(find.text('0:12'), findsOneWidget);
    final bar = tester.widget<SegmentBar>(find.byType(SegmentBar));
    expect(bar.segments.single.value / bar.total!, closeTo(0.2, 0.01));
    await close(tester);
  });

  testWidgets('parar leva pra ouvir e salvar', (tester) async {
    await open(tester);
    await tester.pump(const Duration(seconds: 3));

    await stop(tester);

    expect(device.recording, isFalse);
    expect(find.text('Gravar áudio'), findsOneWidget);
    expect(find.text('Ouça antes de salvar'), findsOneWidget);
    expect(find.byType(AudioClip), findsOneWidget);
    expect(
      find.text(
        'O áudio fica só no seu celular. A gente guarda apenas a transcrição.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('ouvir e salvar cabe em tela estreita', (tester) async {
    await open(tester);
    tester.view.physicalSize = const Size(360, 800);
    await tester.pump();

    await stop(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('para sozinho em 1 minuto', (tester) async {
    await open(tester);

    await tester.pump(const Duration(seconds: 61));

    expect(device.recording, isFalse);
    expect(find.text('Ouça antes de salvar'), findsOneWidget);
  });

  testWidgets('Regravar apaga a gravação e grava de novo', (tester) async {
    await open(tester);
    await stop(tester);

    await tester.tap(find.text('Regravar'));
    await tester.pump();

    expect(device.discarded, ['cache/gravacao-1.m4a']);
    expect(device.recordings, 2);
    expect(find.text('Gravando…'), findsOneWidget);
    await close(tester);
  });

  testWidgets('Salvar no Inbox guarda o áudio e fecha', (tester) async {
    final results = await open(tester);
    await stop(tester);

    await tester.tap(find.byTooltip('Ouvir gravação'));
    await tester.pump();
    await tester.tap(find.text('Salvar no Inbox'));
    await tester.pumpAndSettle();

    final saved = results.single!;
    expect(saved.source, CaptureSource.audio);
    expect(captures.media.files.keys, ['captures/audio/${saved.id}.m4a']);
    expect(device.discarded, ['cache/gravacao-1.m4a']);
    expect(playback.playing, isNull);
    expect(find.byType(AppModal), findsNothing);
  });

  testWidgets('fechar gravando cancela a gravação', (tester) async {
    final results = await open(tester);

    await close(tester);

    expect(results, [null]);
    expect(device.cancelled, 1);
    expect(captures.store.data, isEmpty);
  });

  testWidgets('fechar depois de gravar apaga o arquivo', (tester) async {
    await open(tester);
    await stop(tester);

    await close(tester);

    expect(device.discarded, ['cache/gravacao-1.m4a']);
    expect(captures.store.data, isEmpty);
  });

  testWidgets('microfone negado: aviso leva pras configurações', (
    tester,
  ) async {
    device.microphone = false;
    await open(tester);

    expect(device.recordings, 0);
    expect(find.text('Sem acesso ao microfone'), findsOneWidget);

    await tester.tap(find.text('Abrir configurações'));
    await tester.pumpAndSettle();

    expect(device.settingsOpened, 1);
    expect(find.byType(AppModal), findsNothing);
  });
}
