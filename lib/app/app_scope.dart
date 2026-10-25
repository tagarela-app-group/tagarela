import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:tagarela/data/audio_playback.dart';
import 'package:tagarela/data/capture_device.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    required this.auth,
    required this.captures,
    required this.playback,
    required this.device,
    required this.speech,
    required this.vocabulary,
    required this.language,
    HomeStore? home,
    required super.child,
  }) : home = home ?? HomeStore();

  final AuthStore auth;
  final CaptureStore captures;
  final AudioPlayback playback;
  final CaptureDevice device;
  final SpeechModelStore speech;
  final HomeStore home;
  final VocabularyStore vocabulary;
  final LanguageStore language;

  static AppScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  Future<void> loadAll() async {
    await captures.cleanMedia();
    await Future.wait([home.load(), vocabulary.load(), captures.load()]);
    await captures.extractPending();
    unawaited(speech.whenReady.then((_) => captures.extractPending()));
    unawaited(speech.ensure());
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
