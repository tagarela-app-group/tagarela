import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_api_client.dart';

void main() {
  final db = FakeApiClient().db;
  final groups = db['groups'] as List;
  final terms = db['terms'] as List;
  final inbox = db['inbox'] as List;
  final groupIds = {for (final g in groups) g['id']};

  List<Object?> ids(List list) => [for (final i in list) i['id']];

  test('ids são string e únicos em cada coleção', () {
    for (final list in [groups, terms, inbox]) {
      expect(ids(list), everyElement(isA<String>()));
      expect(ids(list).toSet(), hasLength(list.length));
    }
  });

  test('todo grupo tem termo e todo termo tem grupo', () {
    for (final g in groups) {
      expect(
        terms.where((t) => t['groupId'] == g['id']),
        isNotEmpty,
        reason: '${g['name']}',
      );
    }
    for (final t in terms) {
      expect(groupIds, contains(t['groupId']), reason: '${t['text']}');
    }
  });

  test('nível dos termos entre 0 e 5', () {
    for (final t in terms) {
      expect(t['level'], inInclusiveRange(0, 5), reason: '${t['text']}');
    }
  });

  test('item pronto tem sugestão apontando para grupo existente', () {
    for (final item in inbox.where((i) => i['status'] == 'ready')) {
      final suggestion = item['suggestion'] as Map;
      expect(groupIds, contains(suggestion['groupId']));
      final group = groups.firstWhere((g) => g['id'] == suggestion['groupId']);
      expect(suggestion['groupName'], group['name']);
    }
  });
}
