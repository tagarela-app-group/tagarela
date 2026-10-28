import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/text_extractor.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/data/stores/store.dart';

import '../helpers/fake_vocabulary_api.dart';
import '../helpers/fake_capture_store.dart';
import '../helpers/fake_course_api.dart';
import '../helpers/fake_extraction.dart';
import '../helpers/fake_practice_api.dart';
import '../helpers/pump_app.dart';

void main() {
  test('loadAll carrega todos os stores', () async {
    final scope = fakeDependencies();

    await scope.session.loadAll();

    for (final store in <Store>[
      scope.home,
      scope.vocabulary,
      scope.practice,
      scope.captures,
    ]) {
      expect(store.data, isNotNull, reason: '$store');
    }
  });

  test('sem dados de exemplo: Home e Vocabulário vazios', () async {
    final captures = fakeCaptures();
    final scope = fakeDependencies(
      captures: captures.store,
      home: HomeStore(),
      vocabulary: emptyVocabulary(),
      practice: emptyPractice(),
    );

    await scope.session.loadAll();

    expect(scope.home.data!.wordOfDay, isNull);
    expect(scope.practice.data!.due, 0);
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
    final scope = fakeDependencies(captures: captures.store);

    await scope.session.loadAll();

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
    final scope = fakeDependencies(
      captures: captures.store,
      speech: fakeSpeechModel(ready: true).store,
    );

    await scope.session.loadAll();
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
      final scope = fakeDependencies(
        captures: captures.store,
        speech: speech.store,
      );

      await scope.session.loadAll();
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
    final scope = fakeDependencies(speech: speech.store);

    await scope.session.loadAll();

    expect(speech.storage.downloads, 0);
    expect(scope.speech.state, SpeechModelState.missing);
  });

  test('conta sem curso: loadAll para antes do estudo', () async {
    final vocabulary = fakeVocabulary();
    final scope = fakeDependencies(
      courses: fakeCourses(const []).store,
      vocabulary: vocabulary.store,
    );

    await scope.session.loadAll();

    expect(scope.courses.data, isEmpty);
    expect(vocabulary.api.calls, isEmpty);
    expect(scope.vocabulary.data, isNull);
  });

  test('curso sem áudio não baixa o modelo de fala', () async {
    final speech = fakeSpeechModel();
    final scope = fakeDependencies(
      courses: fakeCourses([
        {...spanishCourseJson, 'active': true},
      ]).store,
      speech: speech.store,
    );

    await scope.session.loadAll();
    await pumpEventQueue();

    expect(speech.storage.downloads, 0);
  });

  test('curso em inglês baixa o modelo de fala', () async {
    final speech = fakeSpeechModel();
    final scope = fakeDependencies(speech: speech.store);

    await scope.session.loadAll();
    await pumpEventQueue();

    expect(speech.storage.downloads, 1);
  });

  test('sair esquece o estudo da conta antes da próxima entrar', () async {
    final app = fakeDependencies();
    await app.auth.login('ana@example.com', 'x');
    await app.session.loadAll();

    await app.session.signOut();

    expect(app.auth.user, isNull);
    for (final store in <Store>[
      app.courses,
      app.home,
      app.vocabulary,
      app.practice,
      app.captures,
    ]) {
      expect(store.data, isNull, reason: '$store');
    }
  });
}
