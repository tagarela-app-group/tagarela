import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/services/user_service.dart';

import '../../helpers/fake_api_client.dart';

void main() {
  test('fetchUser lê /user', () async {
    final api = FakeApiClient();
    final user = await UserService(api).fetchUser();

    expect(api.calls, ['GET /user']);
    expect(user.name, api.db['user']['name']);
    expect(user.streakDays, api.db['user']['streakDays']);
  });
}
