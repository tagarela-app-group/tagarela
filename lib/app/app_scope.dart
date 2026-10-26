import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:tagarela/data/device/audio_playback.dart';
import 'package:tagarela/data/device/capture_device.dart';
import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/data/stores/course_store.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    required this.auth,
    required this.courses,
    required this.captures,
    required this.playback,
    required this.device,
    required this.speech,
    required this.vocabulary,
    required this.language,
    required this.voice,
    HomeStore? home,
    required super.child,
  }) : home = home ?? HomeStore();

  final AuthStore auth;
  final CourseStore courses;
  final CaptureStore captures;
  final AudioPlayback playback;
  final CaptureDevice device;
  final SpeechModelStore speech;
  final HomeStore home;
  final VocabularyStore vocabulary;
  final LanguageStore language;
  final Voice voice;

  static AppScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  Future<void> loadAll() async {
    await captures.cleanMedia();
    await courses.load();
    if (courses.data case []) return;
    await _loadStores();
    await captures.extractPending();
    unawaited(speech.whenReady.then((_) => captures.extractPending()));
    _ensureSpeech();
  }

  Future<void> loadStudy() async {
    await _loadStores();
    _ensureSpeech();
  }

  Future<void> _loadStores() =>
      Future.wait([home.load(), vocabulary.load(), captures.load()]);

  void _ensureSpeech() {
    if (courses.active?.learning.hasAudio ?? true) unawaited(speech.ensure());
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
