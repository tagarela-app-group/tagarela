import 'package:flutter/widgets.dart';

import 'package:tagarela/data/audio_playback.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    required this.auth,
    required this.captures,
    required this.playback,
    HomeStore? home,
    VocabularyStore? vocabulary,
    required super.child,
  }) : home = home ?? HomeStore(),
       vocabulary = vocabulary ?? VocabularyStore();

  final AuthStore auth;
  final CaptureStore captures;
  final AudioPlayback playback;
  final HomeStore home;
  final VocabularyStore vocabulary;

  static AppScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  Future<void> loadAll() async {
    await captures.cleanMedia();
    await Future.wait([home.load(), vocabulary.load(), captures.load()]);
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
