import 'dart:convert';
import 'dart:io';

import 'package:tagarela/data/api_client.dart';

/// API em memória com os dados de `server/db.json`.
/// Imita o json-server no que o app usa: GET, `_embed`, POST, DELETE.
class FakeApiClient implements ApiClient {
  FakeApiClient()
    : db = jsonDecode(File('server/db.json').readAsStringSync()) as Map;

  final Map db;

  /// Chamadas feitas, ex.: `POST /terms`.
  final calls = <String>[];

  /// `true` = toda chamada falha com 500.
  bool failing = false;

  @override
  String get baseUrl => 'fake://';

  @override
  Future<Object?> get(String path) async {
    _record('GET', path);
    final uri = Uri.parse(path);
    final data = _copy(db[uri.pathSegments.single]);
    final embed = uri.queryParameters['_embed'];
    if (embed == null) return data;
    // `/groups?_embed=terms` → cada grupo com seus `terms` (via `groupId`).
    final children = db[embed] as List;
    final key = '${uri.pathSegments.single.replaceAll(RegExp(r's$'), '')}Id';
    for (final parent in data as List) {
      parent[embed] = [
        for (final c in children)
          if (c[key] == parent['id']) _copy(c),
      ];
    }
    return data;
  }

  @override
  Future<Object?> post(String path, Map<String, Object?> body) async {
    _record('POST', path);
    final item = {...body, 'id': '${DateTime.now().microsecondsSinceEpoch}'};
    (db[path.substring(1)] as List).add(item);
    return item;
  }

  @override
  Future<void> delete(String path) async {
    _record('DELETE', path);
    final [_, collection, id] = path.split('/');
    final list = db[collection] as List;
    final before = list.length;
    list.removeWhere((i) => i['id'] == id);
    if (list.length == before) throw ApiException(404, 'DELETE $path');
  }

  void _record(String method, String path) {
    calls.add('$method $path');
    if (failing) throw ApiException(500, '$method $path');
  }

  static Object? _copy(Object? json) => jsonDecode(jsonEncode(json));
}
