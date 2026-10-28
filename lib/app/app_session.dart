import 'dart:async';

import 'package:tagarela/app/app_dependencies.dart';

class AppSession {
  AppSession(this._app);

  final AppDependencies _app;

  Future<void> loadAll() async {
    await _app.captures.cleanMedia();
    await _app.courses.load();
    if (_app.courses.data case []) return;
    await _loadStores();
    await _app.captures.extractPending();
    unawaited(
      _app.speech.whenReady.then((_) => _app.captures.extractPending()),
    );
    _ensureSpeech();
  }

  Future<void> loadStudy() async {
    await _loadStores();
    _ensureSpeech();
  }

  Future<void> _loadStores() => Future.wait([
    _app.home.load(),
    _app.vocabulary.load(),
    _app.practice.load(),
    _app.captures.load(),
  ]);

  void _ensureSpeech() {
    if (_app.courses.active?.learning.hasAudio ?? true) {
      unawaited(_app.speech.ensure());
    }
  }
}
