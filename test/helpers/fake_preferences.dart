import 'package:tagarela/data/preferences.dart';
import 'package:tagarela/data/stores/language_store.dart';

class FakePreferences implements Preferences {
  FakePreferences([this.stored]);

  String? stored;

  @override
  Future<String?> language() async => stored;

  @override
  Future<void> setLanguage(String? code) async => stored = code;
}

LanguageStore fakeLanguage([String? stored]) =>
    LanguageStore(FakePreferences(stored));
