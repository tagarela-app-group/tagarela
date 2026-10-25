import 'package:flutter/widgets.dart';

import 'package:tagarela/data/preferences.dart';

enum AppLanguage {
  pt('Português (Brasil)'),
  en('English'),
  es('Español');

  const AppLanguage(this.label);

  static const fallback = AppLanguage.en;

  final String label;

  Locale get locale => Locale(name);

  static AppLanguage? of(String? code) => values.asNameMap()[code];

  static AppLanguage resolve(Iterable<Locale> preferred) =>
      preferred.map((l) => of(l.languageCode)).nonNulls.firstOrNull ?? fallback;
}

class LanguageStore extends ChangeNotifier {
  LanguageStore(this._preferences);

  final Preferences _preferences;

  AppLanguage? _choice;

  AppLanguage? get choice => _choice;

  Future<void> load() async {
    try {
      _choice = AppLanguage.of(await _preferences.language());
    } on Exception {
      return;
    }
    notifyListeners();
  }

  Future<void> choose(AppLanguage? language) async {
    _choice = language;
    notifyListeners();
    await _preferences.setLanguage(language?.name);
  }
}
