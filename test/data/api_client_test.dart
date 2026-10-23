import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/api_client.dart';

void main() {
  late HttpServer server;
  late ApiClient api;
  final received = <String>[];
  final framing = <(int, bool)>[];

  setUp(() async {
    received.clear();
    framing.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    api = ApiClient(baseUrl: 'http://${server.address.host}:${server.port}');
    server.listen((request) async {
      framing.add((
        request.headers.contentLength,
        request.headers.chunkedTransferEncoding,
      ));
      final body = await utf8.decoder.bind(request).join();
      received.add('${request.method} ${request.uri} $body'.trim());
      final response = request.response;
      switch (request.uri.path) {
        case '/missing':
          response.statusCode = 404;
        case '/html-error':
          response.statusCode = 404;
          response.write('<html>não achou</html>');
        case '/pending':
          response.statusCode = 401;
          response.write(
            jsonEncode({'token': request.headers.value('X-Session-Token')}),
          );
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

  test('POST manda Content-Length em vez de corpo chunked', () async {
    await api.post('/terms', {'text': 'olá'});

    expect(framing, [(utf8.encode('{"text":"olá"}').length, false)]);
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

  test('send devolve status e corpo sem lançar em 4xx, com headers', () async {
    final response = await api.send(
      'POST',
      '/pending',
      body: {'a': 1},
      headers: {'X-Session-Token': 'abc'},
    );

    expect(response.statusCode, 401);
    expect(response.body, {'token': 'abc'});
    expect(received, ['POST /pending {"a":1}']);
  });

  test('send com erro sem JSON devolve corpo nulo', () async {
    final response = await api.send('GET', '/html-error');

    expect((response.statusCode, response.body), (404, null));
  });

  test('servidor fora do ar vira exceção de rede', () async {
    await server.close(force: true);
    expect(api.get('/user'), throwsA(isA<SocketException>()));
  });
}
