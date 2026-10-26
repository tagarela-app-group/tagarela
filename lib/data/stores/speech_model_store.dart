import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:tagarela/data/device/speech_model.dart';
import 'package:tagarela/data/storage/model_storage.dart';

enum SpeechModelState { missing, downloading, ready, failed }

class SpeechModelStore extends ChangeNotifier {
  SpeechModelStore(
    this._storage, {
    this.model = SpeechModel.current,
    this.firstRetry = const Duration(seconds: 30),
  });

  static const maxRetry = Duration(minutes: 10);

  final ModelStorage _storage;
  final SpeechModel model;
  final Duration firstRetry;

  SpeechModelState state = SpeechModelState.missing;
  double progress = 0;

  final _ready = Completer<void>();
  Future<void>? _running;
  Timer? _retry;
  Duration? _lastRetry;

  int get percent => (progress * 100).floor();

  bool get ready => state == SpeechModelState.ready;

  Future<void> get whenReady => _ready.future;

  Future<void> ensure() =>
      _running ??= _ensure().whenComplete(() => _running = null);

  Future<void> _ensure() async {
    if (ready) return;
    _retry?.cancel();
    if (await _storage.installed(model) == null) await _download();
    if (state == SpeechModelState.failed) {
      _scheduleRetry();
      return;
    }
    state = SpeechModelState.ready;
    _lastRetry = null;
    notifyListeners();
    if (!_ready.isCompleted) _ready.complete();
  }

  Future<void> _download() async {
    state = SpeechModelState.downloading;
    progress = 0;
    notifyListeners();
    try {
      await for (final value in _storage.download(model)) {
        final changed = (value * 100).floor() != percent;
        progress = value;
        if (changed) notifyListeners();
      }
    } on Exception {
      state = SpeechModelState.failed;
      notifyListeners();
    }
  }

  void _scheduleRetry() {
    final last = _lastRetry;
    final next = last == null
        ? firstRetry
        : last * 2 < maxRetry
        ? last * 2
        : maxRetry;
    _lastRetry = next;
    _retry = Timer(next, ensure);
  }

  @override
  void dispose() {
    _retry?.cancel();
    super.dispose();
  }
}
