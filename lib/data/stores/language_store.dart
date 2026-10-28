import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/storage/preferences.dart';
import 'package:tagarela/data/stores/course_store.dart';

class LanguageStore extends ChangeNotifier {
  LanguageStore(this._preferences, this._courses) {
    _courses.addListener(_follow);
  }

  final Preferences _preferences;
  final CourseStore _courses;

  CourseLanguage? _saved;

  Locale? get locale => (_courses.active?.base ?? _saved)?.locale;

  Future<void> load() async {
    try {
      _saved = CourseLanguage.of(await _preferences.language());
    } on Exception {
      return;
    }
    notifyListeners();
  }

  void _follow() {
    final base = _courses.active?.base;
    if (base == null || base == _saved) return;
    _saved = base;
    notifyListeners();
    unawaited(_preferences.setLanguage(base.name));
  }

  @override
  void dispose() {
    _courses.removeListener(_follow);
    super.dispose();
  }
}

Locale appLocale(Iterable<Locale> preferred, Iterable<Locale> supported) =>
    preferred
        .map((l) => Locale(l.languageCode))
        .where(supported.contains)
        .firstOrNull ??
    CourseLanguage.en.locale;
