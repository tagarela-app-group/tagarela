import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_scope.dart';
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
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

import 'fake_auth.dart';
import 'fake_capture_store.dart';
import 'fake_course_api.dart';
import 'fake_extraction.dart';
import 'fake_preferences.dart';
import 'fake_vocabulary_api.dart';
import 'fake_voice.dart';
import 'fixtures.dart';

AppScope testScope({
  required Widget child,
  AuthStore? auth,
  CourseStore? courses,
  CaptureStore? captures,
  AudioPlayback? playback,
  CaptureDevice? device,
  SpeechModelStore? speech,
  HomeStore? home,
  VocabularyStore? vocabulary,
  LanguageStore? language,
  Voice? voice,
}) => AppScope(
  auth: auth ?? fakeAuthStore(),
  courses: courses ?? fakeCourses().store,
  captures: captures ?? fakeCaptures().store,
  playback: playback ?? FakeAudioPlayback(),
  device: device ?? FakeCaptureDevice(),
  speech: speech ?? fakeSpeechModel().store,
  home: home ?? HomeStore(sampleHome),
  vocabulary: vocabulary ?? fakeVocabulary().store,
  language: language ?? fakeLanguage(),
  voice: voice ?? FakeVoice(),
  child: child,
);

MaterialApp testApp(
  Widget home, {
  ThemeData? theme,
  Locale locale = const Locale('pt'),
}) => MaterialApp(
  theme: theme ?? AppTheme.light,
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);

extension PumpApp on WidgetTester {
  void useTallScreen() {
    view.physicalSize = const Size(800, 1600);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  }

  Future<AppScope> pumpPage(
    Widget page, {
    AuthStore? auth,
    CourseStore? courses,
    CaptureStore? captures,
    AudioPlayback? playback,
    CaptureDevice? device,
    SpeechModelStore? speech,
    HomeStore? home,
    VocabularyStore? vocabulary,
    LanguageStore? language,
    Voice? voice,
    bool load = true,
    ThemeData? theme,
    Locale locale = const Locale('pt'),
  }) async {
    useTallScreen();
    final scope = testScope(
      auth: auth,
      courses: courses,
      captures: captures,
      playback: playback,
      device: device,
      speech: speech,
      home: home,
      vocabulary: vocabulary,
      language: language,
      voice: voice,
      child: testApp(page, theme: theme, locale: locale),
    );
    if (load) await scope.loadAll();
    await pumpWidget(scope);
    return scope;
  }

  Future<void> pumpComponent(
    Widget child, {
    ThemeData? theme,
    Locale locale = const Locale('pt'),
  }) => pumpPage(
    Scaffold(body: child),
    theme: theme,
    locale: locale,
    load: false,
  );

  Future<void> pumpUntilFound(Finder finder) async {
    for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
      await pump(const Duration(milliseconds: 100));
    }
    await pump(const Duration(seconds: 1));
    await pump();
  }
}

Finder textField(String label) => find.descendant(
  of: find.widgetWithText(AppTextField, label),
  matching: find.byType(TextField),
);
