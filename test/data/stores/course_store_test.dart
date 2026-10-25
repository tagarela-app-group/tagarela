import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';

import '../../helpers/fake_course_api.dart';

void main() {
  test('carrega os cursos e acha o ativo', () async {
    final courses = fakeCourses([englishCourseJson, spanishCourseJson]);

    await courses.store.load();

    expect(courses.store.data!.map((c) => c.id), ['curso-en', 'curso-es']);
    expect(courses.store.active!.learning, CourseLanguage.en);
    expect(courses.store.active!.base, CourseLanguage.pt);
    expect(courses.store.active!.terms, 8);
  });

  test('conta sem curso não tem ativo', () async {
    final courses = fakeCourses(const []);

    await courses.store.load();

    expect(courses.store.data, isEmpty);
    expect(courses.store.active, isNull);
  });

  test('começar curso novo entra no fim e vira o ativo', () async {
    final courses = fakeCourses();
    await courses.store.load();

    final course = await courses.store.start(
      CourseLanguage.es,
      CourseLanguage.en,
    );

    expect(courses.api.bodies['POST /api/v1/courses'], {
      'learning': 'es',
      'base': 'en',
    });
    expect(course.active, isTrue);
    expect(courses.store.data!.map((c) => (c.id, c.active)), [
      ('curso-en', false),
      ('curso-es-en', true),
    ]);
  });

  test('par que já existe só volta a ser o ativo', () async {
    final courses = fakeCourses([spanishCourseJson, englishCourseJson]);
    await courses.store.load();

    await courses.store.start(CourseLanguage.es, CourseLanguage.en);

    expect(courses.store.data!.map((c) => (c.id, c.active)), [
      ('curso-es', true),
      ('curso-en', false),
    ]);
  });

  test('ativar troca o curso ativo', () async {
    final courses = fakeCourses([englishCourseJson, spanishCourseJson]);
    await courses.store.load();

    await courses.store.activate(courses.store.data!.last);

    expect(
      courses.api.calls,
      contains('POST /api/v1/courses/curso-es/activate'),
    );
    expect(courses.store.active!.id, 'curso-es');
    expect(courses.store.data!.first.active, isFalse);
  });

  test('falha ao ativar mantém o curso de antes', () async {
    final courses = fakeCourses([englishCourseJson, spanishCourseJson]);
    await courses.store.load();
    courses.api.offline = true;

    await expectLater(
      courses.store.activate(courses.store.data!.last),
      throwsA(isA<Exception>()),
    );

    expect(courses.store.active!.id, 'curso-en');
  });
}
