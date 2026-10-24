import 'dart:async';
import 'dart:io';

import 'package:tagarela/data/model_storage.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/speech_model.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/data/text_extractor.dart';

class FakeTextExtractor implements TextExtractor {
  final results = <CaptureSource, Object>{};
  final extracted = <String>[];
  int released = 0;
  Completer<void>? hold;

  @override
  Future<String> extract(CaptureSource source, File file) async {
    await hold?.future;
    extracted.add(file.path);
    final result = results[source] ?? 'Mind the gap.';
    if (result is ExtractionError) throw ExtractionException(result);
    return result as String;
  }

  @override
  Future<void> release() async => released++;
}

class FakeModelStorage implements ModelStorage {
  String? path;
  bool offline = false;
  int downloads = 0;
  int removed = 0;
  List<double> steps = const [0.25, 0.5, 1];
  Completer<void>? hold;

  @override
  Future<String?> installed(SpeechModel model) async => path;

  @override
  Stream<double> download(SpeechModel model) async* {
    downloads++;
    if (offline) throw const SocketException('sem rede');
    for (final step in steps) {
      yield step;
    }
    await hold?.future;
    path = 'models/${model.id}';
  }

  @override
  Future<void> remove(SpeechModel model) async {
    removed++;
    path = null;
  }
}

typedef FakeSpeechModel = ({SpeechModelStore store, FakeModelStorage storage});

FakeSpeechModel fakeSpeechModel({bool ready = false}) {
  final storage = FakeModelStorage()
    ..path = ready ? 'models/${SpeechModel.current.id}' : null;
  return (store: SpeechModelStore(storage), storage: storage);
}
