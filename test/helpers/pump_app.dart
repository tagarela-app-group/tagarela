import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/design_system/design_system.dart';

import 'fake_api_client.dart';
import 'fake_auth.dart';

extension PumpApp on WidgetTester {
  void useTallScreen() {
    view.physicalSize = const Size(800, 1600);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  }

  Future<AppScope> pumpPage(
    Widget page, {
    FakeApiClient? api,
    AuthStore? auth,
    bool load = true,
    ThemeData? theme,
  }) async {
    useTallScreen();
    final scope = AppScope(
      api: api ?? FakeApiClient(),
      auth: auth ?? fakeAuthStore(),
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
