import 'dart:async';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

import 'fake_api.dart';
import 'fixtures.dart';

class FakeVocabularyApi extends FakeApi {
  FakeVocabularyApi([Json seed = sampleVocabularyJson]) {
    final copy = FakeApi.copyJson(seed)! as Json;
    groups.addAll([for (final g in copy['groups']! as List) g as Json]);
    ungrouped.addAll([for (final t in copy['ungrouped']! as List) t as Json]);
  }

  final groups = <Json>[];
  final ungrouped = <Json>[];
  final cards = <String, Json>{};
  final seen = <String, List<Json>>{};
  final revealed = <String>{};
  final pitfallRevealed = <String>{};
  final formalityRevealed = <String>{};
  final termFields = <String, Json>{};
  Completer<void>? holdCard;
  final _deleted = <({Json term, String? groupId})>[];

  var _ids = 0;

  @override
  Future<Object?> get(String path, {Duration? timeout}) async {
    if (path.startsWith(_termPath)) await holdCard?.future;
    return super.get(path);
  }

  @override
  Object? respond(String method, String path, Map<String, Object?>? body) =>
      switch (method) {
        'GET' => path.startsWith(_termPath) ? _detail(path) : _vocabulary(),
        'POST' => _post(path, body!),
        'PATCH' => _patch(path, body!),
        'DELETE' => _delete(path),
        _ => throw UnimplementedError(),
      };

  Json _post(String path, Map<String, Object?> body) {
    if (path == '/api/v1/groups') return _createGroup(body);
    final ids = [for (final id in body['terms']! as List) id as String];
    switch (path) {
      case '/api/v1/terms/delete':
        _deleted
          ..clear()
          ..addAll(_take(ids));
      case '/api/v1/terms/restore':
        _restore(ids);
      default:
        _move(ids, body['group'] as String?);
    }
    return _vocabulary();
  }

  Json _patch(String path, Map<String, Object?> body) {
    if (!path.startsWith(_termPath)) {
      return _updateGroup(_groupOf(path), body);
    }
    final id = path.substring(_termPath.length);
    for (final (key, ids) in [
      ('revealed', revealed),
      ('pitfall_revealed', pitfallRevealed),
      ('formality_revealed', formalityRevealed),
    ]) {
      if (body[key] case final bool on) on ? ids.add(id) : ids.remove(id);
    }
    return _detail(path);
  }

  Json _delete(String path) {
    final group = _groupOf(path);
    groups.remove(group);
    ungrouped.insertAll(0, (group['terms']! as List).cast<Json>());
    return _vocabulary();
  }

  List<String> termsOf(String? groupId) => [
    for (final t in groupId == null ? ungrouped : _terms(groupId))
      t['text']! as String,
  ];

  Json _createGroup(Map<String, Object?> body) {
    final name = body['name']! as String;
    _checkName(name, 'POST /api/v1/groups');
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

  Json _updateGroup(Json group, Map<String, Object?> body) {
    if (body['name'] case final String name) {
      _checkName(name, 'PATCH /api/v1/groups/${group['id']}', except: group);
    }
    group.addAll(body);
    return group;
  }

  void _checkName(String name, String route, {Json? except}) {
    if (groups.any(
      (g) =>
          g != except &&
          (g['name']! as String).toLowerCase() == name.toLowerCase(),
    )) {
      throw ApiException(400, route, {
        'name': ['Você já tem um grupo com esse nome.'],
      });
    }
  }

  Json _groupOf(String path) =>
      groups.firstWhere((g) => path.endsWith('/${g['id']}'));

  List<({Json term, String? groupId})> _take(List<String> ids) {
    final taken = <({Json term, String? groupId})>[];
    for (final (groupId, list) in [
      (null, ungrouped),
      for (final g in groups) (g['id'] as String?, _terms(g['id'])),
    ]) {
      taken.addAll([
        for (final t in list)
          if (ids.contains(t['id'])) (term: t, groupId: groupId),
      ]);
      list.removeWhere((t) => ids.contains(t['id']));
    }
    return taken;
  }

  void _move(List<String> ids, String? groupId) =>
      (groupId == null ? ungrouped : _terms(groupId)).insertAll(0, [
        for (final t in _take(ids)) t.term,
      ]);

  void _restore(List<String> ids) {
    if (!ids.every((id) => _deleted.any((d) => d.term['id'] == id))) {
      throw ApiException(400, 'POST /api/v1/terms/restore', {
        'terms': ['Não dá mais pra desfazer.'],
      });
    }
    for (final d in _deleted.where((d) => ids.contains(d.term['id']))) {
      final inGroup = groups.any((g) => g['id'] == d.groupId);
      (inGroup ? _terms(d.groupId) : ungrouped).insert(0, d.term);
    }
    _deleted.removeWhere((d) => ids.contains(d.term['id']));
  }

  List<Json> _terms(Object? groupId) =>
      (groups.firstWhere((g) => g['id'] == groupId)['terms']! as List)
          .cast<Json>();

  Json _vocabulary() => {'groups': groups, 'ungrouped': ungrouped};

  static const _termPath = '/api/v1/terms/';

  Json _detail(String path) {
    final id = path.substring(_termPath.length);
    final group = groups
        .where((g) => _terms(g['id']).any((t) => t['id'] == id))
        .firstOrNull;
    final term = [
      ...ungrouped,
      for (final g in groups) ..._terms(g['id']),
    ].firstWhere((t) => t['id'] == id);
    return {
      ...term,
      'group': group == null
          ? null
          : {
              'id': group['id'],
              'name': group['name'],
              'icon': group['icon'],
              'accent': group['accent'],
            },
      ...?termFields[id],
      'revealed': revealed.contains(id),
      'pitfall_revealed': pitfallRevealed.contains(id),
      'formality_revealed': formalityRevealed.contains(id),
      'card': cards[id] ?? sampleCardJson,
      'captures': seen[id] ?? const <Json>[],
    };
  }
}

typedef FakeVocabulary = ({VocabularyStore store, FakeVocabularyApi api});

FakeVocabulary fakeVocabulary([
  Json seed = sampleVocabularyJson,
  Future<void> Function()? onTermsChanged,
]) {
  final api = FakeVocabularyApi(seed);
  return (
    store: VocabularyStore(
      VocabularyService(api),
      onTermsChanged: onTermsChanged,
    ),
    api: api,
  );
}

VocabularyStore emptyVocabulary() => fakeVocabulary(const {
  'groups': <Object?>[],
  'ungrouped': <Object?>[],
}).store;
