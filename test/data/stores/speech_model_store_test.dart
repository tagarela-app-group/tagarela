import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/stores/speech_model_store.dart';

import '../../helpers/fake_extraction.dart';

void main() {
  test('load: sem modelo = missing, baixado = ready', () async {
    final missing = fakeSpeechModel();
    final ready = fakeSpeechModel(ready: true);

    await missing.store.load();
    await ready.store.load();

    expect(missing.store.state, SpeechModelState.missing);
    expect(ready.store.state, SpeechModelState.ready);
  });

  test('download: avisa cada novo percentual e fica pronto', () async {
    final (:store, :storage) = fakeSpeechModel();
    storage.steps = const [0.004, 0.009, 0.5, 1];
    final seen = <(SpeechModelState, int)>[];
    store.addListener(() => seen.add((store.state, store.percent)));

    await store.download();

    expect(seen, [
      (SpeechModelState.downloading, 0),
      (SpeechModelState.downloading, 50),
      (SpeechModelState.downloading, 100),
      (SpeechModelState.ready, 100),
    ]);
    expect(await storage.installed(store.model), isNotNull);
  });

  test('download sem rede: failed, e tentar de novo funciona', () async {
    final (:store, :storage) = fakeSpeechModel();
    storage.offline = true;

    await store.download();
    expect(store.state, SpeechModelState.failed);

    storage.offline = false;
    await store.download();
    expect(store.state, SpeechModelState.ready);
    expect(storage.downloads, 2);
  });

  test('baixando: não baixa de novo nem remove, load não muda', () async {
    final (:store, :storage) = fakeSpeechModel();
    storage.hold = Completer();

    final first = store.download();
    await Future<void>.delayed(Duration.zero);
    await store.download();
    await store.remove();
    await store.load();

    expect(store.state, SpeechModelState.downloading);
    expect(storage.downloads, 1);
    expect(storage.removed, 0);

    storage.hold!.complete();
    await first;
    expect(store.state, SpeechModelState.ready);
  });

  test('remove: apaga e volta pra missing', () async {
    final (:store, :storage) = fakeSpeechModel(ready: true);
    await store.load();

    await store.remove();

    expect(store.state, SpeechModelState.missing);
    expect(store.progress, 0);
    expect(storage.removed, 1);
  });
}
