import 'dart:convert';
import 'dart:io';

import 'package:tagarela/data/models/errors.dart';

typedef AccessToken = Future<String?> Function({bool renew});

class ApiClient {
  ApiClient({this.baseUrl = defaultBaseUrl, this.accessToken});

  static const defaultBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const _timeout = Duration(seconds: 10);

  final String baseUrl;
  final AccessToken? accessToken;
  final _http = HttpClient()..connectionTimeout = _timeout;

  Future<Object?> get(String path, {Duration? timeout}) =>
      _send('GET', path, timeout: timeout);

  Future<Object?> post(String path, Map<String, Object?> body) =>
      _send('POST', path, body: body);

  Future<Object?> patch(String path, Map<String, Object?> body) =>
      _send('PATCH', path, body: body);

  Future<Object?> delete(String path) => _send('DELETE', path);

  Future<ApiResponse> send(
    String method,
    String path, {
    Object? body,
    Map<String, String> headers = const {},
    Duration? timeout,
  }) {
    final bytes = body == null ? null : utf8.encode(jsonEncode(body));
    return _authorized(
      (auth) => _request(method, path, ContentType.json, bytes, {
        ...headers,
        ...auth,
      }, timeout ?? _timeout),
    );
  }

  Future<Object?> _send(
    String method,
    String path, {
    Object? body,
    Duration? timeout,
  }) async => _checked(
    await send(method, path, body: body, timeout: timeout),
    method,
    path,
  );

  Future<ApiResponse> _authorized(
    Future<ApiResponse> Function(Map<String, String> auth) request,
  ) async {
    final source = accessToken;
    if (source == null) return request(const {});
    final token = await source();
    final response = await request(_bearer(token));
    if (response.statusCode != HttpStatus.unauthorized || token == null) {
      return response;
    }
    final renewed = await source(renew: true);
    if (renewed == null) return response;
    return request(_bearer(renewed));
  }

  Future<ApiResponse> _request(
    String method,
    String path,
    ContentType contentType,
    List<int>? bytes,
    Map<String, String> headers,
    Duration timeout,
  ) async {
    final request = await _http.openUrl(method, Uri.parse('$baseUrl$path'));
    request.headers.contentType = contentType;
    headers.forEach(request.headers.set);
    if (bytes != null) {
      request.contentLength = bytes.length;
      request.add(bytes);
    }

    final response = await request.close().timeout(timeout);
    final text = await response.transform(utf8.decoder).join();
    return ApiResponse(response.statusCode, _decode(text, response.statusCode));
  }

  static Map<String, String> _bearer(String? token) => {
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Object? _checked(ApiResponse response, String method, String path) {
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, '$method $path', response.body);
    }
    return response.body;
  }

  static Object? _decode(String text, int statusCode) {
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      if (statusCode >= 400) return null;
      rethrow;
    }
  }
}

class ApiResponse {
  const ApiResponse(this.statusCode, this.body);

  final int statusCode;
  final Object? body;
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.request, [this.body]);

  final int statusCode;
  final String request;
  final Object? body;

  Map<String, String> get fieldErrors => switch (body) {
    final Map<String, Object?> json => {
      for (final MapEntry(:key, :value) in json.entries)
        if (value case [final String message, ...]) key: message,
    },
    _ => const {},
  };

  Exception get forApp =>
      rejected ? RejectedException(fieldErrors) : const ServerException();

  bool get rejected =>
      statusCode >= 400 &&
      statusCode < 500 &&
      statusCode != HttpStatus.unauthorized;

  @override
  String toString() => 'ApiException: $statusCode em $request';
}
