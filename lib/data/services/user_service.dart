import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';

class UserService {
  const UserService(this._api);

  final ApiClient _api;

  Future<User> fetchUser() async =>
      User.fromJson(await _api.get('/user') as Json);
}
