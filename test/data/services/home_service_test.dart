import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/services/home_service.dart';

import '../../helpers/fake_api_client.dart';

void main() {
  test('fetchStats lê /stats', () async {
    final api = FakeApiClient();
    final stats = await HomeService(api).fetchStats();

    expect(api.calls, ['GET /stats']);
    expect(stats.reviewCount, api.db['stats']['reviewCount']);
  });

  test('fetchWordOfDay lê /wordOfDay', () async {
    final api = FakeApiClient();
    final word = await HomeService(api).fetchWordOfDay();

    expect(api.calls, ['GET /wordOfDay']);
    expect(word.text, api.db['wordOfDay']['text']);
  });
}
