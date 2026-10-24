import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/stores/speech_model_store.dart';

import '../../helpers/fake_extraction.dart';

void main() {
  test('ensure com modelo instalado: pronto sem baixar', () async {
    final (:store, :storage) = fakeSpeechModel(ready: true);
    var ready = false;
    unawaited(store.whenReady.then((_) => ready = true));

    await store.ensure();
    await Future<void>.delayed(Duration.zero);

    expect(store.state, SpeechModelState.ready);
    expect(storage.downloads, 0);
    expect(ready, isTrue);
  });

  test(
    'ensure sem modelo: baixa, avisa cada novo percentual e fica pronto',
    () async {
      final (:store, :storage) = fakeSpeechModel();
      storage.steps = const [0.004, 0.009, 0.5, 1];
      final seen = <(SpeechModelState, int)>[];
      store.addListener(() => seen.add((store.state, store.percent)));

      await store.ensure();

      expect(seen, [
        (SpeechModelState.downloading, 0),
        (SpeechModelState.downloading, 50),
        (SpeechModelState.downloading, 100),
        (SpeechModelState.ready, 100),
      ]);
      expect(await storage.installed(store.model), isNotNull);
    },
  );

  test('ensure enquanto baixa não baixa de novo', () async {
    final (:store, :storage) = fakeSpeechModel();
    storage.hold = Completer();

    final first = store.ensure();
    await Future<void>.delayed(Duration.zero);
    final second = store.ensure();

    expect(store.state, SpeechModelState.downloading);
    storage.hold!.complete();
    await Future.wait([first, second]);

    expect(store.state, SpeechModelState.ready);
    expect(storage.downloads, 1);
  });

  test('pronto: ensure não faz nada', () async {
    final (:store, :storage) = fakeSpeechModel();
    await store.ensure();

    await store.ensure();

    expect(storage.downloads, 1);
  });

  testWidgets('sem rede: tenta de novo sozinho, com espera dobrando', (
    tester,
  ) async {
    final (:store, :storage) = fakeSpeechModel(
      firstRetry: const Duration(seconds: 30),
    );
    storage.offline = true;

    await store.ensure();
    expect(store.state, SpeechModelState.failed);

    await tester.pump(const Duration(seconds: 29));
    expect(storage.downloads, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(storage.downloads, 2);

    await tester.pump(const Duration(seconds: 59));
    expect(storage.downloads, 2);
    storage.offline = false;
    await tester.pump(const Duration(seconds: 1));

    expect(storage.downloads, 3);
    expect(store.state, SpeechModelState.ready);
    store.dispose();
  });

  testWidgets('espera máxima de 10 min entre tentativas', (tester) async {
    final (:store, :storage) = fakeSpeechModel(
      firstRetry: const Duration(minutes: 4),
    );
    storage.offline = true;

    await store.ensure();
    await tester.pump(const Duration(minutes: 4));
    await tester.pump(const Duration(minutes: 8));
    expect(storage.downloads, 3);

    await tester.pump(SpeechModelStore.maxRetry - const Duration(seconds: 1));
    expect(storage.downloads, 3);
    await tester.pump(const Duration(seconds: 1));
    expect(storage.downloads, 4);
    store.dispose();
  });

  testWidgets('dispose cancela a próxima tentativa', (tester) async {
    final (:store, :storage) = fakeSpeechModel();
    storage.offline = true;
    await store.ensure();

    store.dispose();
    await tester.pump(const Duration(minutes: 1));

    expect(storage.downloads, 1);
  });
}
