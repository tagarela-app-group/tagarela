import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';

import 'fake_api_client.dart';

extension PumpApp on WidgetTester {
  void useTallScreen() {
    view.physicalSize = const Size(800, 1600);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  }

  Future<AppScope> pumpPage(
    Widget page, {
    FakeApiClient? api,
    bool load = true,
    ThemeData? theme,
  }) async {
    useTallScreen();
    final scope = AppScope(
      api: api ?? FakeApiClient(),
      child: MaterialApp(theme: theme ?? AppTheme.light, home: page),
    );
    if (load) await scope.loadAll();
    await pumpWidget(scope);
    return scope;
  }

  Future<void> pumpComponent(Widget child, {ThemeData? theme}) =>
      pumpPage(Scaffold(body: child), theme: theme, load: false);
}
