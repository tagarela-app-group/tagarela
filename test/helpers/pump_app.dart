import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/audio_playback.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';
import 'package:tagarela/design_system/design_system.dart';

import 'fake_auth.dart';
import 'fake_capture_store.dart';
import 'fixtures.dart';

AppScope testScope({
  required Widget child,
  AuthStore? auth,
  CaptureStore? captures,
  AudioPlayback? playback,
  HomeStore? home,
  VocabularyStore? vocabulary,
}) => AppScope(
  auth: auth ?? fakeAuthStore(),
  captures: captures ?? fakeCaptures().store,
  playback: playback ?? FakeAudioPlayback(),
  home: home ?? HomeStore(sampleHome),
  vocabulary: vocabulary ?? VocabularyStore(sampleGroups),
  child: child,
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
    CaptureStore? captures,
    AudioPlayback? playback,
    HomeStore? home,
    VocabularyStore? vocabulary,
    bool load = true,
    ThemeData? theme,
  }) async {
    useTallScreen();
    final scope = testScope(
      auth: auth,
      captures: captures,
      playback: playback,
      home: home,
      vocabulary: vocabulary,
      child: MaterialApp(theme: theme ?? AppTheme.light, home: page),
    );
    if (load) await scope.loadAll();
    await pumpWidget(scope);
    return scope;
  }

  Future<void> pumpComponent(Widget child, {ThemeData? theme}) =>
      pumpPage(Scaffold(body: child), theme: theme, load: false);
}

Finder textField(String label) => find.descendant(
  of: find.widgetWithText(AppTextField, label),
  matching: find.byType(TextField),
);
