import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Preferences([SharedPreferencesAsync? preferences]) : _given = preferences;

  static const _language = 'language';

  final SharedPreferencesAsync? _given;
  late final SharedPreferencesAsync _preferences =
      _given ?? SharedPreferencesAsync();

  Future<String?> language() => _preferences.getString(_language);

  Future<void> setLanguage(String? code) => code == null
      ? _preferences.remove(_language)
      : _preferences.setString(_language, code);
}
