import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/stores/home_store.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('sem fonte: vazia até a API ter o recurso', () async {
    final store = HomeStore();

    await store.load();

    expect(store.data!.wordOfDay, isNull);
    expect(store.data!.stats.weekGain, 0);
  });

  test('com dados devolve o que recebeu', () async {
    final store = HomeStore(sampleHome);

    await store.load();

    expect(store.data, same(sampleHome));
  });
}
