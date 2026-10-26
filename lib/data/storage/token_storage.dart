import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:tagarela/data/models/models.dart';

class TokenStorage {
  TokenStorage([this._storage = const FlutterSecureStorage()]);

  static const _key = 'refresh_token';
  static const _userKey = 'user';

  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _key);

  Future<void> write(String token) => _storage.write(key: _key, value: token);

  Future<User?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    return raw == null ? null : User.fromJson(jsonDecode(raw) as Json);
  }

  Future<void> writeUser(User user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  Future<void> clear() async {
    await _storage.delete(key: _key);
    await _storage.delete(key: _userKey);
  }
}
