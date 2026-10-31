import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';

class AccountService {
  const AccountService(this._api);

  final ApiClient _api;

  Future<User> update({required String country}) async => User.fromJson(
    await _api.patch('/api/v1/account', {'country': country}) as Json,
  );
}
