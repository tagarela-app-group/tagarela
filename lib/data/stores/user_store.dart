import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/user_service.dart';
import 'package:tagarela/data/store.dart';

class UserStore extends Store<User> {
  UserStore(this._service);

  final UserService _service;

  @override
  Future<User> fetch() => _service.fetchUser();
}
