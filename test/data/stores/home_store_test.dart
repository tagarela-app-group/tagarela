import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/stores/home_store.dart';

void main() {
  test('sem fonte: vazia até a API ter o recurso', () async {
    final store = HomeStore();

    await store.load();

    expect(store.data!.wordOfDay, isNull);
    expect(store.data!.stats.weekGain, 0);
  });
}
