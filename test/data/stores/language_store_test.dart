import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/l10n/l10n.dart';

import '../../helpers/fake_course_api.dart';
import '../../helpers/fake_preferences.dart';

class _BrokenPreferences extends FakePreferences {
  @override
  Future<String?> language() => Future.error(Exception('disco'));
}

void main() {
  group('appLocale', () {
    const supported = AppLocalizations.supportedLocales;

    test('primeiro idioma do aparelho que o app tem', () {
      expect(
        appLocale(const [Locale('fr'), Locale('es', 'MX')], supported),
        const Locale('es'),
      );
      expect(
        appLocale(const [Locale('pt', 'PT')], supported),
        const Locale('pt'),
      );
    });

    test('nenhum idioma conhecido cai no inglês', () {
      expect(appLocale(const [Locale('fr')], supported), const Locale('en'));
      expect(appLocale(const [], supported), const Locale('en'));
    });

    test('todo idioma do app pode ser o que a pessoa fala no curso', () {
      for (final locale in supported) {
        expect(CourseLanguage.of(locale.languageCode)?.locale, locale);
      }
    });
  });

  test('sem curso nem idioma salvo segue o aparelho', () async {
    final store = fakeLanguage(fakeCourses(const []).store);

    await store.load();

    expect(store.locale, isNull);
  });

  test('idioma salvo vale até os cursos chegarem', () async {
    final courses = fakeCourses([
      {...englishCourseJson, 'base': 'es'},
    ]);
    final store = fakeLanguage(courses.store, 'en');

    await store.load();
    expect(store.locale, const Locale('en'));

    await courses.store.load();
    expect(store.locale, const Locale('es'));
  });

  test('código salvo desconhecido é ignorado', () async {
    final store = fakeLanguage(fakeCourses(const []).store, 'fr');

    await store.load();

    expect(store.locale, isNull);
  });

  test('segue o que a pessoa fala no curso ativo e salva', () async {
    final courses = fakeCourses([englishCourseJson, spanishCourseJson]);
    final preferences = FakePreferences();
    final store = LanguageStore(preferences, courses.store);
    var notified = 0;
    store.addListener(() => notified++);

    await courses.store.load();
    expect(store.locale, const Locale('pt'));
    expect(preferences.stored, 'pt');

    await courses.store.activate(courses.store.data!.last);
    expect(store.locale, const Locale('en'));
    expect(preferences.stored, 'en');
    expect(notified, 2);
  });

  test('curso novo com a mesma base não avisa de novo', () async {
    final courses = fakeCourses();
    final store = fakeLanguage(courses.store);
    await courses.store.load();
    var notified = 0;
    store.addListener(() => notified++);

    await courses.store.start(CourseLanguage.es, CourseLanguage.pt);

    expect(store.locale, const Locale('pt'));
    expect(notified, 0);
  });

  test('falha ao ler mantém o idioma do aparelho', () async {
    final store = LanguageStore(_BrokenPreferences(), fakeCourses().store);

    await store.load();

    expect(store.locale, isNull);
  });

  test('descartado para de seguir os cursos', () async {
    final courses = fakeCourses();
    final preferences = FakePreferences();
    LanguageStore(preferences, courses.store).dispose();

    await courses.store.load();

    expect(preferences.stored, isNull);
  });
}
