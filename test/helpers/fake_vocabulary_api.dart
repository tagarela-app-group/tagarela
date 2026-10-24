import 'dart:convert';
import 'dart:io';

import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

import 'fixtures.dart';

class FakeVocabularyApi implements ApiClient {
  FakeVocabularyApi([Json seed = sampleVocabularyJson]) {
    final copy = _copy(seed) as Json;
    groups.addAll([for (final g in copy['groups']! as List) g as Json]);
    ungrouped.addAll([for (final t in copy['ungrouped']! as List) t as Json]);
  }

  final groups = <Json>[];
  final ungrouped = <Json>[];
  final calls = <String>[];
  final bodies = <String, Object?>{};
  final rejections = <String, int>{};

  bool offline = false;
  var _ids = 0;

  @override
  String get baseUrl => 'fake-vocabulary://';

  @override
  AccessToken? get accessToken => null;

  @override
  Future<Object?> get(String path) =>
      _handle('GET', path, null, () => _vocabulary());

  @override
  Future<Object?> post(String path, Map<String, Object?> body) =>
      _handle('POST', path, body, () {
        if (path == '/api/v1/groups') return _createGroup(body);
        _move([
          for (final id in body['terms']! as List) id as String,
        ], body['group'] as String?);
        return _vocabulary();
      });

  @override
  Future<Object?> patch(String path, Map<String, Object?> body) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String path) => throw UnimplementedError();

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Object? body,
    Map<String, String> headers = const {},
  }) => throw UnimplementedError();

  List<String> termsOf(String? groupId) => [
    for (final t in groupId == null ? ungrouped : _terms(groupId))
      t['text']! as String,
  ];

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
    return _copy(handler());
  }

  Json _createGroup(Map<String, Object?> body) {
    final name = body['name']! as String;
    if (groups.any(
      (g) => (g['name']! as String).toLowerCase() == name.toLowerCase(),
    )) {
      throw ApiException(400, 'POST /api/v1/groups', {
        'name': ['Você já tem um grupo com esse nome.'],
      });
    }
    final group = <String, Object?>{
      'id': 'novo-${++_ids}',
      'name': name,
      'icon': body['icon'],
      'accent': body['accent'],
      'terms': <Object?>[],
    };
    groups.insert(0, group);
    return group;
  }

  void _move(List<String> ids, String? groupId) {
    final moved = <Json>[];
    for (final list in [ungrouped, for (final g in groups) _terms(g['id'])]) {
      moved.addAll(list.where((t) => ids.contains(t['id'])));
      list.removeWhere((t) => ids.contains(t['id']));
    }
    (groupId == null ? ungrouped : _terms(groupId)).insertAll(0, moved);
  }

  List<Json> _terms(Object? groupId) =>
      (groups.firstWhere((g) => g['id'] == groupId)['terms']! as List)
          .cast<Json>();

  Json _vocabulary() => {'groups': groups, 'ungrouped': ungrouped};

  static Object? _copy(Object? json) => jsonDecode(jsonEncode(json));
}

typedef FakeVocabulary = ({VocabularyStore store, FakeVocabularyApi api});

FakeVocabulary fakeVocabulary([Json seed = sampleVocabularyJson]) {
  final api = FakeVocabularyApi(seed);
  return (store: VocabularyStore(VocabularyService(api)), api: api);
}

VocabularyStore emptyVocabulary() => fakeVocabulary(const {
  'groups': <Object?>[],
  'ungrouped': <Object?>[],
}).store;
