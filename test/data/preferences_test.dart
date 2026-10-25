import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:tagarela/data/preferences.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('guarda, lê e apaga o idioma', () async {
    final preferences = Preferences();
    expect(await preferences.language(), isNull);

    await preferences.setLanguage('es');
    expect(await Preferences().language(), 'es');

    await preferences.setLanguage(null);
    expect(await Preferences().language(), isNull);
  });
}
