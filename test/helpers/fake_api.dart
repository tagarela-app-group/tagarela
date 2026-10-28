import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:tagarela/data/services/api_client.dart';

abstract class FakeApi implements ApiClient {
  final calls = <String>[];
  final bodies = <String, Object?>{};
  final rejections = <String, int>{};

  bool offline = false;

  @override
  String get baseUrl => 'fake://';

  @override
  AccessToken? get accessToken => null;

  @override
  Future<Object?> get(String path, {Duration? timeout}) =>
      handle('GET', path, null);

  @override
  Future<Object?> post(String path, Map<String, Object?> body) =>
      handle('POST', path, body);

  @override
  Future<Object?> patch(String path, Map<String, Object?> body) =>
      handle('PATCH', path, body);

  @override
  Future<Object?> delete(String path) => handle('DELETE', path, null);

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Object? body,
    Map<String, String> headers = const {},
    Duration? timeout,
  }) => throw UnimplementedError();

  @protected
  FutureOr<Object?> respond(
    String method,
    String path,
    Map<String, Object?>? body,
  );

  @protected
  Future<Object?> handle(
    String method,
    String path,
    Map<String, Object?>? body,
  ) async {
    final route = '$method $path';
    calls.add(route);
    bodies[route] = body;
    if (offline) throw const SocketException('sem rede');
    if (rejections[route] case final status?) {
      throw ApiException(status, route);
    }
    return copyJson(await respond(method, path, body));
  }

  static Object? copyJson(Object? json) => jsonDecode(jsonEncode(json));
}
