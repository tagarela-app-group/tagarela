import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';

class CaptureService {
  const CaptureService(this._api);

  static const _path = '/api/v1/captures';

  final ApiClient _api;

  Future<Capture> create(Capture capture) async => Capture.fromJson(
    await _api.post(_path, {
          'id': capture.id,
          'course': ?capture.course,
          'source': capture.source.name,
          'captured_at': capture.capturedAt.toUtc().toIso8601String(),
          'text': capture.text,
        })
        as Json,
  );

  Future<Capture> update(Capture capture) async => Capture.fromJson(
    await _api.patch('$_path/${capture.id}', {
          'text': capture.text,
          'terms': [for (final t in capture.terms) t.toJson()],
        })
        as Json,
  );

  Future<Capture> confirm(String id) async =>
      Capture.fromJson(await _api.post('$_path/$id/confirm', {}) as Json);

  Future<void> discard(String id) => _api.delete('$_path/$id');

  Future<List<Capture>> changes(DateTime? since) async {
    final captures = <Capture>[];
    String? cursor;
    do {
      final query = {
        if (since != null) 'updated_since': since.toUtc().toIso8601String(),
        'cursor': ?cursor,
      };
      final page =
          await _api.get(
                Uri(
                  path: _path,
                  queryParameters: query.isEmpty ? null : query,
                ).toString(),
              )
              as Json;
      captures.addAll([
        for (final c in page['results']! as List<Object?>)
          Capture.fromJson(c! as Json),
      ]);
      cursor = switch (page['next']) {
        final String next => Uri.parse(next).queryParameters['cursor'],
        _ => null,
      };
    } while (cursor != null);
    return captures;
  }
}
