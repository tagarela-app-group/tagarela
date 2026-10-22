import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/inbox_service.dart';

import '../../helpers/fake_api_client.dart';

void main() {
  late FakeApiClient api;
  late InboxService service;

  setUp(() {
    api = FakeApiClient();
    service = InboxService(api);
  });

  Future<InboxItem> firstReady() async => (await service.fetchItems())
      .firstWhere((i) => i.status == InboxStatus.ready);

  test('fetchItems lê /inbox', () async {
    final items = await service.fetchItems();

    expect(api.calls, ['GET /inbox']);
    expect(items, hasLength((api.db['inbox'] as List).length));
  });

  test('accept cria termo no grupo sugerido e tira do Inbox', () async {
    final item = await firstReady();
    api.calls.clear();

    await service.accept(item);

    expect(api.calls, ['POST /terms', 'DELETE /inbox/${item.id}']);
    final created = (api.db['terms'] as List).last as Map;
    expect(created, {
      'groupId': item.suggestion!.groupId,
      'text': item.content,
      'translation': item.suggestion!.translation,
      'kind': item.suggestion!.kind.name,
      'level': 0,
      'id': isA<String>(),
    });
    expect(
      (await service.fetchItems()).map((i) => i.id),
      isNot(contains(item.id)),
    );
  });

  test('discard só tira do Inbox', () async {
    final item = await firstReady();
    api.calls.clear();

    await service.discard(item);

    expect(api.calls, ['DELETE /inbox/${item.id}']);
  });
}
