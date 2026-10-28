import 'dart:async';

import 'package:tagarela/app/app_dependencies.dart';
import 'package:tagarela/data/stores/store.dart';

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

  Future<void> signOut() async {
    await _app.auth.logout();
    for (final store in [_app.courses, ..._study]) {
      store.clear();
    }
  }

  List<Store<Object>> get _study => [
    _app.home,
    _app.vocabulary,
    _app.practice,
    _app.captures,
  ];

  Future<void> _loadStores() =>
      Future.wait([for (final store in _study) store.load()]);

  void _ensureSpeech() {
    if (_app.courses.active?.learning.hasAudio ?? true) {
      unawaited(_app.speech.ensure());
    }
  }
}
