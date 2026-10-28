import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/course_service.dart';
import 'package:tagarela/data/stores/course_store.dart';

import 'fake_api.dart';

const Json englishCourseJson = {
  'id': 'curso-en',
  'learning': 'en',
  'base': 'pt',
  'active': true,
  'terms': 8,
};

const Json spanishCourseJson = {
  'id': 'curso-es',
  'learning': 'es',
  'base': 'en',
  'active': false,
  'terms': 2,
};

class FakeCourseApi extends FakeApi {
  FakeCourseApi([List<Json> seed = const [englishCourseJson]])
    : courses = [for (final c in seed) Map.of(c)];

  static const _path = '/api/v1/courses';

  final List<Json> courses;

  @override
  Object? respond(String method, String path, Map<String, Object?>? body) =>
      switch (method) {
        'GET' => courses,
        'POST' => _post(path, body!),
        _ => throw UnimplementedError(),
      };

  Json _post(String path, Map<String, Object?> body) {
    if (path.endsWith('/activate')) {
      return _activate(
        courses.firstWhere((c) => path == '$_path/${c['id']}/activate'),
      );
    }
    final existing = courses.where(
      (c) => c['learning'] == body['learning'] && c['base'] == body['base'],
    );
    if (existing.firstOrNull case final course?) return _activate(course);
    final course = <String, Object?>{
      'id': 'curso-${body['learning']}-${body['base']}',
      'learning': body['learning'],
      'base': body['base'],
      'terms': 0,
    };
    courses.add(course);
    return _activate(course);
  }

  Json _activate(Json course) {
    for (final c in courses) {
      c['active'] = c == course;
    }
    return course;
  }
}

typedef FakeCourses = ({CourseStore store, FakeCourseApi api});

FakeCourses fakeCourses([List<Json> seed = const [englishCourseJson]]) {
  final api = FakeCourseApi(seed);
  return (store: CourseStore(CourseService(api)), api: api);
}
