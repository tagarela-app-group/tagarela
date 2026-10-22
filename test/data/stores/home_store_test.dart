import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/services/home_service.dart';
import 'package:tagarela/data/stores/home_store.dart';

import '../../helpers/fake_api_client.dart';

void main() {
  test('junta stats e palavra do dia', () async {
    final api = FakeApiClient();
    final store = HomeStore(HomeService(api));

    await store.load();

    expect(api.calls, ['GET /stats', 'GET /wordOfDay']);
    expect(store.data!.stats.weekGain, api.db['stats']['weekGain']);
    expect(store.data!.wordOfDay.text, api.db['wordOfDay']['text']);
  });

  test('falha em qualquer chamada vira erro', () async {
    final store = HomeStore(HomeService(FakeApiClient()..failing = true));

    await store.load();

    expect(store.data, isNull);
    expect(store.error, isNotNull);
  });
}
