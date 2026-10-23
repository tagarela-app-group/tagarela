import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/api_client.dart';

void main() {
  late HttpServer server;
  late ApiClient api;
  final received = <String>[];

  setUp(() async {
    received.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    api = ApiClient(baseUrl: 'http://${server.address.host}:${server.port}');
    server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      received.add('${request.method} ${request.uri} $body'.trim());
      final response = request.response;
      switch (request.uri.path) {
        case '/missing':
          response.statusCode = 404;
        case '/empty':
          break;
        default:
          response.write(jsonEncode({'ok': true, 'nome': 'ação'}));
      }
      await response.close();
    });
  });

  tearDown(() => server.close(force: true));

  test('GET decodifica JSON em UTF-8', () async {
    expect(await api.get('/user'), {'ok': true, 'nome': 'ação'});
    expect(received, ['GET /user']);
  });

  test('POST envia corpo JSON', () async {
    await api.post('/terms', {'text': 'olá'});
    expect(received, ['POST /terms {"text":"olá"}']);
  });

  test('DELETE com resposta vazia', () async {
    await api.delete('/empty');
    expect(received, ['DELETE /empty']);
  });

  test('status 4xx/5xx vira ApiException', () async {
    expect(
      api.get('/missing'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.toString(), 'toString', contains('GET /missing')),
      ),
    );
  });

  test('servidor fora do ar vira exceção de rede', () async {
    await server.close(force: true);
    expect(api.get('/user'), throwsA(isA<SocketException>()));
  });
}
