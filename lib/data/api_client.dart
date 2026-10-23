import 'dart:convert';
import 'dart:io';

class ApiClient {
  ApiClient({this.baseUrl = defaultBaseUrl});

  static const defaultBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const authBaseUrl = String.fromEnvironment(
    'AUTH_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const _timeout = Duration(seconds: 10);

  final String baseUrl;
  final _http = HttpClient()..connectionTimeout = _timeout;

  Future<Object?> get(String path) => _send('GET', path);

  Future<Object?> post(String path, Map<String, Object?> body) =>
      _send('POST', path, body);

  Future<void> delete(String path) => _send('DELETE', path);

  Future<ApiResponse> send(
    String method,
    String path, {
    Object? body,
    Map<String, String> headers = const {},
  }) async {
    final request = await _http.openUrl(method, Uri.parse('$baseUrl$path'));
    request.headers.contentType = ContentType.json;
    headers.forEach(request.headers.set);
    if (body != null) {
      final bytes = utf8.encode(jsonEncode(body));
      request.contentLength = bytes.length;
      request.add(bytes);
    }

    final response = await request.close().timeout(_timeout);
    final text = await response.transform(utf8.decoder).join();
    return ApiResponse(response.statusCode, _decode(text, response.statusCode));
  }

  Future<Object?> _send(String method, String path, [Object? body]) async {
    final response = await send(method, path, body: body);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, '$method $path');
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
  const ApiException(this.statusCode, this.request);

  final int statusCode;
  final String request;

  @override
  String toString() => 'ApiException: $statusCode em $request';
}
