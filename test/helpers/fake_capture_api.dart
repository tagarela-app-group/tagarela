import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';

import 'fake_api.dart';

class FakeCaptureApi extends FakeApi {
  static const path = '/api/v1/captures';
  static const pageSize = 2;

  final server = <String, Json>{};

  var _clock = DateTime.utc(2026, 10, 23, 10);

  @override
  Object? respond(String method, String path, Map<String, Object?>? body) =>
      switch (method) {
        'GET' => _list(path),
        'POST' => _post(path, body!),
        'PATCH' => _touch(_capture(path)..addAll(body!)),
        'DELETE' => _touch(_capture(path)..['discarded_at'] = _now()),
        _ => throw UnimplementedError(),
      };

  Json _list(String path) {
    final query = Uri.parse(path).queryParameters;
    final since = switch (query['updated_since']) {
      final String s => DateTime.parse(s),
      _ => null,
    };
    final matching = [
      for (final c in server.values)
        if (since == null
            ? c['discarded_at'] == null
            : !DateTime.parse(c['updated_at']! as String).isBefore(since))
          c,
    ];
    final offset = int.parse(query['cursor'] ?? '0');
    final end = offset + pageSize;
    return {
      'next': end < matching.length
          ? 'http://api.test${FakeCaptureApi.path}?cursor=$end'
          : null,
      'results': matching.sublist(offset, end.clamp(0, matching.length)),
    };
  }

  Json _post(String path, Map<String, Object?> body) {
    if (path.endsWith('/confirm')) {
      return _touch(
        _capture(path)
          ..['status'] = 'analyzed'
          ..['analyzed_at'] = _now(),
      );
    }
    final text = body['text']! as String;
    return server[body['id']! as String] = _touch({
      'id': body['id'],
      'course': body['course'] ?? 'curso-en',
      'source': body['source'],
      'status': 'ready',
      'text': text,
      'original_text': text,
      'terms': <Object?>[],
      'captured_at': body['captured_at'],
      'processed_at': _now(),
      'analyzed_at': null,
      'discarded_at': null,
    });
  }

  Json _capture(String path) =>
      server[path.split('/')[4]] ?? (throw ApiException(404, path));

  Json _touch(Json capture) {
    _clock = _clock.add(const Duration(seconds: 1));
    return capture..['updated_at'] = _now();
  }

  String _now() => _clock.toIso8601String();
}
