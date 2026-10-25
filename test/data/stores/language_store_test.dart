import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/l10n/l10n.dart';

import '../../helpers/fake_preferences.dart';

class _BrokenPreferences extends FakePreferences {
  @override
  Future<String?> language() => Future.error(Exception('disco'));
}

void main() {
  group('AppLanguage.resolve', () {
    test('primeiro idioma do aparelho que o app tem', () {
      expect(
        AppLanguage.resolve(const [Locale('fr'), Locale('es', 'MX')]),
        AppLanguage.es,
      );
      expect(AppLanguage.resolve(const [Locale('pt', 'PT')]), AppLanguage.pt);
      expect(AppLanguage.resolve(const [Locale('en', 'GB')]), AppLanguage.en);
    });

    test('nenhum idioma conhecido cai no inglês', () {
      expect(AppLanguage.resolve(const [Locale('fr')]), AppLanguage.en);
      expect(AppLanguage.resolve(const []), AppLanguage.en);
    });

    test('um idioma por locale do app', () {
      expect(
        AppLanguage.values.map((l) => l.locale).toSet(),
        AppLocalizations.supportedLocales.toSet(),
      );
    });
  });

  test('sem escolha salva segue o aparelho', () async {
    final store = fakeLanguage();

    await store.load();

    expect(store.choice, isNull);
  });

  test('carrega a escolha salva e ignora código desconhecido', () async {
    final saved = fakeLanguage('es');
    final unknown = fakeLanguage('fr');

    await saved.load();
    await unknown.load();

    expect(saved.choice, AppLanguage.es);
    expect(unknown.choice, isNull);
  });

  test('escolher avisa e salva; voltar pro automático apaga', () async {
    final preferences = FakePreferences();
    final store = LanguageStore(preferences);
    var notified = 0;
    store.addListener(() => notified++);

    await store.choose(AppLanguage.en);
    expect(store.choice, AppLanguage.en);
    expect(preferences.stored, 'en');

    await store.choose(null);
    expect(store.choice, isNull);
    expect(preferences.stored, isNull);
    expect(notified, 2);
  });

  test('falha ao ler mantém o idioma do aparelho', () async {
    final store = LanguageStore(_BrokenPreferences());

    await store.load();

    expect(store.choice, isNull);
  });
}
