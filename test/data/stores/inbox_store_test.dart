import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/inbox_service.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/stores/inbox_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

import '../../helpers/fake_api_client.dart';

void main() {
  late FakeApiClient api;
  late VocabularyStore vocabulary;
  late InboxStore inbox;

  setUp(() async {
    api = FakeApiClient();
    vocabulary = VocabularyStore(VocabularyService(api));
    inbox = InboxStore(InboxService(api), vocabulary: vocabulary);
    await Future.wait([vocabulary.load(), inbox.load()]);
  });

  InboxItem firstReady() =>
      inbox.data!.firstWhere((i) => i.status == InboxStatus.ready);

  test('accept tira o item e recarrega o vocabulário', () async {
    final item = firstReady();
    final termsBefore = vocabulary.data!.termCount;

    await inbox.accept(item);

    expect(inbox.data!.map((i) => i.id), isNot(contains(item.id)));
    expect(vocabulary.data!.termCount, termsBefore + 1);
  });

  test('discard tira o item sem mexer no vocabulário', () async {
    final item = firstReady();
    api.calls.clear();

    await inbox.discard(item);

    expect(inbox.data!.map((i) => i.id), isNot(contains(item.id)));
    expect(api.calls, ['DELETE /inbox/${item.id}']);
  });

  test('falha da API sobe e mantém o item', () async {
    final item = firstReady();
    api.failing = true;

    await expectLater(inbox.accept(item), throwsA(isA<ApiException>()));
    await expectLater(inbox.discard(item), throwsA(isA<ApiException>()));

    expect(inbox.data!.map((i) => i.id), contains(item.id));
  });
}
