import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';

class CourseService {
  const CourseService(this._api);

  static const _path = '/api/v1/courses';

  final ApiClient _api;

  Future<List<Course>> fetch() async => [
    for (final c in await _api.get(_path) as List<Object?>)
      Course.fromJson(c! as Json),
  ];

  Future<Course> start(CourseLanguage learning, CourseLanguage base) async =>
      Course.fromJson(
        await _api.post(_path, {'learning': learning.name, 'base': base.name})
            as Json,
      );

  Future<Course> activate(String id) async =>
      Course.fromJson(await _api.post('$_path/$id/activate', {}) as Json);
}
