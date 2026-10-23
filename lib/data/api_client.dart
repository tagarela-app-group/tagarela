import 'dart:convert';
import 'dart:io';

class ApiClient {
  ApiClient({this.baseUrl = defaultBaseUrl});

  static const defaultBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const _timeout = Duration(seconds: 10);

  final String baseUrl;
  final _http = HttpClient()..connectionTimeout = _timeout;

  Future<Object?> get(String path) => _send('GET', path);

  Future<Object?> post(String path, Map<String, Object?> body) =>
      _send('POST', path, body);

  Future<void> delete(String path) => _send('DELETE', path);

  Future<Object?> _send(String method, String path, [Object? body]) async {
    final request = await _http.openUrl(method, Uri.parse('$baseUrl$path'));
    request.headers.contentType = ContentType.json;
    if (body != null) request.add(utf8.encode(jsonEncode(body)));

    final response = await request.close().timeout(_timeout);
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, '$method $path');
    }
    return text.isEmpty ? null : jsonDecode(text);
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.request);

  final int statusCode;
  final String request;

  @override
  String toString() => 'ApiException: $statusCode em $request';
}
