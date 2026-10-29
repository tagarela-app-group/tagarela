import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/services/api_client.dart';

void main() {
  late HttpServer server;
  late ApiClient api;
  final received = <String>[];
  final framing = <(int, bool)>[];
  final authorization = <String?>[];
  final contentTypes = <String?>[];

  ApiClient withToken(AccessToken accessToken) => ApiClient(
    baseUrl: 'http://${server.address.host}:${server.port}',
    accessToken: accessToken,
  );

  setUp(() async {
    received.clear();
    framing.clear();
    authorization.clear();
    contentTypes.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    api = ApiClient(baseUrl: 'http://${server.address.host}:${server.port}');
    server.listen((request) async {
      framing.add((
        request.headers.contentLength,
        request.headers.chunkedTransferEncoding,
      ));
      authorization.add(request.headers.value('Authorization'));
      contentTypes.add(request.headers.value('Content-Type'));
      final body = await utf8.decoder.bind(request).join();
      received.add('${request.method} ${request.uri} $body'.trim());
      final response = request.response;
      switch (request.uri.path) {
        case '/missing':
          response.statusCode = 404;
        case '/invalid':
          response.statusCode = 400;
          response.write(
            jsonEncode({
              'name': ['Você já tem um grupo com esse nome.'],
            }),
          );
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
        case '/slow':
          await Future<void>.delayed(const Duration(milliseconds: 300));
          response.write(jsonEncode({'ok': true}));
        case '/secure'
            when request.headers.value('Authorization') != 'Bearer novo':
          response.statusCode = 401;
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

  test('GET aceita prazo próprio pra resposta lenta', () async {
    await expectLater(
      api.get('/slow', timeout: const Duration(milliseconds: 50)),
      throwsA(isA<TimeoutException>()),
    );
    expect(await api.get('/slow', timeout: const Duration(seconds: 5)), {
      'ok': true,
    });
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

  test('ApiException traz o corpo e a mensagem do campo', () async {
    final error = await api
        .post('/invalid', {})
        .then<ApiException?>(
          (_) => null,
          onError: (Object e) => e as ApiException,
        );

    expect(error!.statusCode, 400);
    expect(error.fieldErrors['name'], 'Você já tem um grupo com esse nome.');
    expect(error.fieldErrors['icon'], isNull);
    expect(const ApiException(500, 'x').fieldErrors['name'], isNull);
  });

  test('fieldErrors pega a 1ª mensagem de cada campo e ignora o resto', () {
    const error = ApiException(400, 'x', {
      'name': ['Curto demais.', 'Outro.'],
      'icon': ['Inválido.'],
      'detail': 'Texto solto.',
      'accent': <Object?>[],
    });

    expect(error.fieldErrors, {'name': 'Curto demais.', 'icon': 'Inválido.'});
    expect(const ApiException(400, 'x', 'texto').fieldErrors, isEmpty);
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

  test('PATCH envia corpo JSON', () async {
    await api.patch('/captures/1', {'text': 'olá'});
    expect(received, ['PATCH /captures/1 {"text":"olá"}']);
  });

  test('sem fonte de token não manda Authorization', () async {
    await api.get('/user');
    expect(authorization, [null]);
  });

  test('manda Bearer; 401 renova uma vez e repete', () async {
    final renews = <bool>[];
    final secure = withToken(({renew = false}) async {
      renews.add(renew);
      return renew ? 'novo' : 'velho';
    });

    expect(await secure.get('/secure'), {'ok': true, 'nome': 'ação'});
    expect(authorization, ['Bearer velho', 'Bearer novo']);
    expect(renews, [false, true]);
  });

  test('renovação recusada devolve o 401 sem repetir', () async {
    final secure = withToken(({renew = false}) async => renew ? null : 'velho');

    await expectLater(
      secure.get('/secure'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
    expect(authorization, ['Bearer velho']);
  });

  test('rejected: 4xx menos 401', () {
    expect(
      [400, 404, 409, 401, 500].map((s) => ApiException(s, 'x').rejected),
      [true, true, true, false, false],
    );
  });

  test('servidor fora do ar vira exceção de rede', () async {
    await server.close(force: true);
    expect(api.get('/user'), throwsA(isA<SocketException>()));
  });

  test('padrão é localhost, que o adb reverse leva a qualquer aparelho', () {
    expect(ApiClient().baseUrl, 'http://localhost:8000');
  });
}
