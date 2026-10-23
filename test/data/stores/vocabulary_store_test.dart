import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/stores/vocabulary_store.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('sem fonte: sem grupos', () async {
    final store = VocabularyStore();

    await store.load();

    expect(store.data, isEmpty);
  });

  test('com dados devolve os grupos', () async {
    final store = VocabularyStore(sampleGroups);

    await store.load();

    expect(store.data, same(sampleGroups));
  });
}
