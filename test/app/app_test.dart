import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app.dart';
import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/stores/course_store.dart';
import 'package:tagarela/features/auth/login_page.dart';

import '../helpers/fake_course_api.dart';
import '../helpers/fake_preferences.dart';
import '../helpers/pump_app.dart';

void main() {
  Future<CourseStore> pumpApp(
    WidgetTester tester, {
    String? saved,
    List<Locale> device = const [Locale('pt', 'BR')],
    FakeCourses? courses,
  }) async {
    tester.useTallScreen();
    tester.platformDispatcher.localesTestValue = device;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final store = (courses ?? fakeCourses(const [])).store;
    await tester.pumpWidget(
      AppScope(
        dependencies: fakeDependencies(
          courses: store,
          language: fakeLanguage(store, saved),
        ),
        child: const TagarelaApp(),
      ),
    );
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('app sem sessão abre no login', (tester) async {
    await pumpApp(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);
  });

  testWidgets('sem idioma salvo segue o aparelho', (tester) async {
    await pumpApp(tester, device: const [Locale('es', 'AR')]);

    expect(find.text('Continuar con Google'), findsOneWidget);
  });

  testWidgets('aparelho em idioma que o app não tem abre em inglês', (
    tester,
  ) async {
    await pumpApp(tester, device: const [Locale('fr', 'FR')]);

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('idioma salvo vence o aparelho', (tester) async {
    await pumpApp(tester, saved: 'en');

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('app fala o idioma do curso ativo e troca junto com ele', (
    tester,
  ) async {
    final courses = await pumpApp(
      tester,
      saved: 'en',
      courses: fakeCourses([
        {...englishCourseJson, 'active': false},
        {...spanishCourseJson, 'base': 'es', 'learning': 'en', 'active': true},
      ]),
    );

    await courses.load();
    await tester.pumpAndSettle();
    expect(find.text('Continuar con Google'), findsOneWidget);

    await courses.activate(courses.data!.first);
    await tester.pumpAndSettle();
    expect(find.text('Continuar com Google'), findsOneWidget);
  });
}
