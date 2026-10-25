import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/store.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/data/text_extractor.dart';

import '../helpers/fake_vocabulary_api.dart';
import '../helpers/fake_auth.dart';
import '../helpers/fake_capture_store.dart';
import '../helpers/fake_course_api.dart';
import '../helpers/fake_extraction.dart';
import '../helpers/fake_preferences.dart';
import '../helpers/fake_voice.dart';
import '../helpers/pump_app.dart';

void main() {
  test('loadAll carrega todos os stores', () async {
    final scope = testScope(child: const SizedBox());

    await scope.loadAll();

    for (final store in <Store>[scope.home, scope.vocabulary, scope.captures]) {
      expect(store.data, isNotNull, reason: '$store');
    }
  });

  test('sem dados de exemplo: Home e Vocabulário vazios', () async {
    final captures = fakeCaptures();
    final scope = AppScope(
      auth: fakeAuthStore(),
      courses: fakeCourses().store,
      captures: captures.store,
      playback: FakeAudioPlayback(),
      device: FakeCaptureDevice(),
      speech: fakeSpeechModel().store,
      vocabulary: emptyVocabulary(),
      language: fakeLanguage(),
      voice: FakeVoice(),
      child: const SizedBox(),
    );

    await scope.loadAll();

    expect(scope.home.data!.wordOfDay, isNull);
    expect(scope.home.data!.stats.reviewCount, 0);
    expect(scope.vocabulary.data!.isEmpty, isTrue);
  });

  test('loadAll limpa mídia vencida antes de listar', () async {
    final captures = fakeCaptures();
    const path = 'captures/photo/c1.jpg';
    captures.media.files[path] = File(path);
    await captures.db.saveCapture(
      'ana@example.com',
      sampleCapture(
        'c1',
        source: CaptureSource.photo,
        status: CaptureStatus.analyzed,
        mediaPath: path,
      ).copyWith(analyzedAt: DateTime(2020)),
    );
    final scope = testScope(captures: captures.store, child: const SizedBox());

    await scope.loadAll();

    expect(captures.media.files, isEmpty);
    expect(scope.captures.data!.single.mediaPath, isNull);
  });

  test('loadAll lê o modelo e retoma a extração pendente', () async {
    final captures = fakeCaptures(extractor: FakeTextExtractor());
    const path = 'captures/photo/c1.jpg';
    captures.media.files[path] = File(path);
    await captures.db.saveCapture(
      'ana@example.com',
      sampleCapture(
        'c1',
        source: CaptureSource.photo,
        status: CaptureStatus.processing,
        text: '',
        mediaPath: path,
        pending: const {CaptureSync.extract, CaptureSync.create},
      ),
    );
    final scope = testScope(
      captures: captures.store,
      speech: fakeSpeechModel(ready: true).store,
      child: const SizedBox(),
    );

    await scope.loadAll();
    await scope.speech.whenReady;
    await captures.store.extractions;

    expect(scope.speech.state, SpeechModelState.ready);
    expect(scope.captures.data!.single.status, CaptureStatus.ready);
    expect(scope.captures.data!.single.text, 'Mind the gap.');
    expect(captures.api.server, contains('c1'));
  });

  test(
    'loadAll baixa o modelo sozinho e transcreve o áudio que esperava',
    () async {
      final extractor = FakeTextExtractor()
        ..results[CaptureSource.audio] = ExtractionError.modelMissing;
      final captures = fakeCaptures(extractor: extractor);
      const path = 'captures/audio/a1.m4a';
      captures.media.files[path] = File(path);
      await captures.db.saveCapture(
        'ana@example.com',
        sampleCapture(
          'a1',
          source: CaptureSource.audio,
          status: CaptureStatus.processing,
          text: '',
          mediaPath: path,
          pending: const {CaptureSync.extract, CaptureSync.create},
        ),
      );
      final speech = fakeSpeechModel();
      speech.storage.hold = Completer();
      final scope = testScope(
        captures: captures.store,
        speech: speech.store,
        child: const SizedBox(),
      );

      await scope.loadAll();
      await captures.store.extractions;

      expect(speech.storage.downloads, 1);
      expect(scope.speech.state, SpeechModelState.downloading);
      expect(scope.captures.data!.single.status, CaptureStatus.processing);

      extractor.results.remove(CaptureSource.audio);
      speech.storage.hold!.complete();
      await scope.speech.whenReady;
      await Future<void>.delayed(Duration.zero);
      await captures.store.extractions;

      expect(scope.captures.data!.single.status, CaptureStatus.ready);
      expect(scope.captures.data!.single.text, 'Mind the gap.');
    },
  );

  test('modo servidor: loadAll não baixa o modelo', () async {
    final speech = fakeSpeechModel();
    final scope = testScope(speech: speech.store, child: const SizedBox());

    await scope.loadAll();

    expect(speech.storage.downloads, 0);
    expect(scope.speech.state, SpeechModelState.missing);
  });

  testWidgets('of acha o escopo na árvore', (tester) async {
    late AppScope found;
    final scope = testScope(
      child: Builder(
        builder: (context) {
          found = AppScope.of(context);
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(scope);

    expect(found, same(scope));
    expect(scope.updateShouldNotify(scope), isFalse);
  });

  test('conta sem curso: loadAll para antes do estudo', () async {
    final vocabulary = fakeVocabulary();
    final scope = testScope(
      courses: fakeCourses(const []).store,
      vocabulary: vocabulary.store,
      child: const SizedBox(),
    );

    await scope.loadAll();

    expect(scope.courses.data, isEmpty);
    expect(vocabulary.api.calls, isEmpty);
    expect(scope.vocabulary.data, isNull);
  });

  test('curso sem áudio não baixa o modelo de fala', () async {
    final speech = fakeSpeechModel();
    final scope = testScope(
      courses: fakeCourses([
        {...spanishCourseJson, 'active': true},
      ]).store,
      speech: speech.store,
      child: const SizedBox(),
    );

    await scope.loadAll();
    await pumpEventQueue();

    expect(speech.storage.downloads, 0);
  });

  test('curso em inglês baixa o modelo de fala', () async {
    final speech = fakeSpeechModel();
    final scope = testScope(speech: speech.store, child: const SizedBox());

    await scope.loadAll();
    await pumpEventQueue();

    expect(speech.storage.downloads, 1);
  });
}
