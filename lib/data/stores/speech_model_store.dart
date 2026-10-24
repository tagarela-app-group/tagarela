import 'package:flutter/foundation.dart';

import 'package:tagarela/data/model_storage.dart';
import 'package:tagarela/data/speech_model.dart';

enum SpeechModelState { missing, downloading, ready, failed }

class SpeechModelStore extends ChangeNotifier {
  SpeechModelStore(this._storage, {this.model = SpeechModel.current});

  final ModelStorage _storage;
  final SpeechModel model;

  SpeechModelState state = SpeechModelState.missing;
  double progress = 0;

  int get percent => (progress * 100).floor();

  Future<void> load() async {
    if (state == SpeechModelState.downloading) return;
    final ready = await _storage.installed(model) != null;
    state = ready ? SpeechModelState.ready : SpeechModelState.missing;
    notifyListeners();
  }

  Future<void> download() async {
    if (state == SpeechModelState.downloading) return;
    state = SpeechModelState.downloading;
    progress = 0;
    notifyListeners();
    try {
      await for (final value in _storage.download(model)) {
        final changed = (value * 100).floor() != percent;
        progress = value;
        if (changed) notifyListeners();
      }
      state = SpeechModelState.ready;
    } on Exception {
      state = SpeechModelState.failed;
    }
    notifyListeners();
  }

  Future<void> remove() async {
    if (state == SpeechModelState.downloading) return;
    await _storage.remove(model);
    state = SpeechModelState.missing;
    progress = 0;
    notifyListeners();
  }
}
