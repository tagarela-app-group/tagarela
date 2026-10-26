import 'dart:convert';
import 'dart:io';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/data/services/course_service.dart';
import 'package:tagarela/data/stores/course_store.dart';

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

class FakeCourseApi implements ApiClient {
  FakeCourseApi([List<Json> seed = const [englishCourseJson]])
    : courses = [for (final c in seed) Map.of(c)];

  static const _path = '/api/v1/courses';

  final List<Json> courses;
  final calls = <String>[];
  final bodies = <String, Object?>{};
  final rejections = <String, int>{};

  bool offline = false;

  @override
  String get baseUrl => 'fake-courses://';

  @override
  AccessToken? get accessToken => null;

  @override
  Future<Object?> get(String path, {Duration? timeout}) =>
      _handle('GET', path, null, () => courses);

  @override
  Future<Object?> post(String path, Map<String, Object?> body) =>
      _handle('POST', path, body, () {
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
      });

  @override
  Future<Object?> patch(String path, Map<String, Object?> body) =>
      throw UnimplementedError();

  @override
  Future<Object?> delete(String path) => throw UnimplementedError();

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Object? body,
    Map<String, String> headers = const {},
    Duration? timeout,
  }) => throw UnimplementedError();

  Json _activate(Json course) {
    for (final c in courses) {
      c['active'] = c == course;
    }
    return course;
  }

  Future<Object?> _handle(
    String method,
    String path,
    Object? body,
    Object? Function() handler,
  ) async {
    final route = '$method $path';
    calls.add(route);
    bodies[route] = body;
    if (offline) throw const SocketException('sem rede');
    if (rejections[route] case final status?) {
      throw ApiException(status, route);
    }
    return jsonDecode(jsonEncode(handler()));
  }
}

typedef FakeCourses = ({CourseStore store, FakeCourseApi api});

FakeCourses fakeCourses([List<Json> seed = const [englishCourseJson]]) {
  final api = FakeCourseApi(seed);
  return (store: CourseStore(CourseService(api)), api: api);
}
