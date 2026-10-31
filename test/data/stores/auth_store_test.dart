import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/data/stores/auth_store.dart';

import '../../helpers/fake_auth.dart';

void main() {
  late FakeAuthApi api;
  late FakeTokenStorage storage;
  late FakeSocialSignIn social;
  late AuthStore store;

  setUp(() {
    api = FakeAuthApi();
    storage = FakeTokenStorage();
    social = FakeSocialSignIn();
    store = fakeAuthStore(api: api, storage: storage, social: social);
  });

  group('updateCountry', () {
    test('salva o país e guarda o usuário novo', () async {
      await store.login('ana@example.com', 'x');
      var notified = 0;
      store.addListener(() => notified++);

      await store.updateCountry('BR');

      expect(store.user?.country, 'BR');
      expect(storage.user?.country, 'BR');
      expect(api.last('PATCH /api/v1/account').body, {'country': 'BR'});
      expect(notified, 1);
    });

    test('sem país manda vazio pra limpar', () async {
      await store.login('ana@example.com', 'x');
      api.responses['PATCH /api/v1/account'] = const ApiResponse(
        200,
        FakeAuthApi.user,
      );

      await store.updateCountry(null);

      expect(api.last('PATCH /api/v1/account').body, {'country': ''});
      expect(store.user?.country, isNull);
    });

    test('falha mantém o usuário e repassa o erro', () async {
      await store.login('ana@example.com', 'x');
      api.responses['PATCH /api/v1/account'] = const ApiResponse(500, null);

      await expectLater(
        store.updateCountry('BR'),
        throwsA(isA<ApiException>()),
      );
      expect(store.user?.country, isNull);
    });

    test('deslogado não chama a API', () async {
      await store.updateCountry('BR');

      expect(api.requests, isEmpty);
    });
  });

  group('restore', () {
    test('sem token salvo: deslogado, sem chamar a API', () async {
      expect(await store.restore(), isFalse);
      expect(api.requests, isEmpty);
    });

    test(
      'token válido: logado, guarda o refresh novo e busca o usuário',
      () async {
        storage.token = 'refresh-1';

        expect(await store.restore(), isTrue);
        expect(store.isSignedIn, isTrue);
        expect(storage.token, 'refresh-2');
        expect(store.user?.name, 'Ana Souza');
        expect(storage.user?.picture, 'https://example.com/ana.png');
        expect(
          api.last('GET /auth/session').headers['Authorization'],
          'Bearer access-2',
        );
      },
    );

    test('sessão falha depois do refresh: guarda o refresh novo', () async {
      storage.token = 'refresh-1';
      api.responses['GET /auth/session'] = const ApiResponse(500, null);

      expect(await store.restore(), isTrue);
      expect(storage.token, 'refresh-2');
    });

    test('token recusado: deslogado e apaga o token', () async {
      storage.token = 'velho';
      api.responses['POST /tokens/refresh'] = FakeAuthApi.errors({
        'refresh_token': 'Inválido.',
      });

      expect(await store.restore(), isFalse);
      expect(store.isSignedIn, isFalse);
      expect(storage.token, isNull);
    });

    test('sem rede: entra com o token e o usuário salvos', () async {
      storage.token = 'refresh-1';
      storage.user = const User(name: 'Ana', email: 'ana@example.com');
      api.error = const SocketException('offline');

      expect(await store.restore(), isTrue);
      expect(storage.token, 'refresh-1');
      expect(store.user?.name, 'Ana');
    });
  });

  test('login salva o refresh token e avisa', () async {
    var notified = 0;
    store.addListener(() => notified++);

    final result = await store.login('ana@example.com', 'x');

    expect(result, isA<AuthSignedIn>());
    expect((store.isSignedIn, storage.token), (true, 'refresh-1'));
    expect(notified, greaterThan(0));
  });

  test('login guarda o usuário da resposta', () async {
    await store.login('ana@example.com', 'x');

    expect(store.user?.name, 'Ana Souza');
    expect(storage.user?.email, 'ana@example.com');
  });

  test('etapa pendente não salva token', () async {
    final result = await store.signup('Ana', 'ana@example.com', 'x');

    expect(result, isA<AuthPending>());
    expect((store.isSignedIn, storage.token), (false, null));
  });

  test('verificar e-mail e trocar senha salvam token', () async {
    await store.verifyEmail('123456', 'session-1');
    expect(storage.token, 'refresh-1');

    await store.logout();
    await store.resetPassword('123456', 'nova', 'session-1');
    expect(storage.token, 'refresh-1');
  });

  test('Google e Apple mandam o token do provider pra API', () async {
    await store.signInWithGoogle();
    expect(social.googleClientId, 'web-client-id');
    expect(
      (api.last('POST /auth/provider/token').body! as Map)['provider'],
      'google',
    );

    await store.signInWithApple();
    expect(
      (api.last('POST /auth/provider/token').body! as Map)['provider'],
      'apple',
    );
    expect(store.isSignedIn, isTrue);
  });

  test('Google sem client_id na API falha sem abrir o Google', () async {
    api.responses['GET /config'] = FakeAuthApi.config({});

    await expectLater(store.signInWithGoogle(), throwsA(isA<AuthException>()));
    expect(social.googleClientId, isNull);
    expect(api.routes, ['GET /config']);
  });

  test('login social cancelado devolve null sem logar', () async {
    social.googleToken = null;

    expect(await store.signInWithGoogle(), isNull);
    expect(api.routes, ['GET /config']);
  });

  test('logout apaga o token e encerra a sessão na API', () async {
    await store.login('ana@example.com', 'x');

    await store.logout();

    expect((store.isSignedIn, storage.token), (false, null));
    expect((store.user, storage.user), (null, null));
    expect(api.routes, [
      'POST /auth/login',
      'POST /tokens/refresh',
      'DELETE /auth/session',
    ]);
    expect(
      api.last('DELETE /auth/session').headers['Authorization'],
      'Bearer access-2',
    );
  });

  test('logout sem rede apaga o token mesmo assim', () async {
    await store.login('ana@example.com', 'x');
    api.error = const SocketException('offline');

    await store.logout();

    expect((store.isSignedIn, storage.token), (false, null));
  });

  group('accessToken', () {
    test('sem sessão: null, sem chamar a API', () async {
      expect(await store.accessToken(), isNull);
      expect(api.requests, isEmpty);
    });

    test('depois do login: usa o access do login, sem refresh', () async {
      await store.login('ana@example.com', 'x');

      expect(await store.accessToken(), 'access-1');
      expect(api.routes, isNot(contains('POST /tokens/refresh')));
    });

    test('renew: troca o par e guarda o refresh novo', () async {
      await store.login('ana@example.com', 'x');

      expect(await store.accessToken(renew: true), 'access-2');
      expect(api.last('POST /tokens/refresh').body, {
        'refresh_token': 'refresh-1',
      });
      expect(storage.token, 'refresh-2');
    });

    test('sessão restaurada offline: busca access no primeiro uso', () async {
      storage.token = 'refresh-1';
      api.error = const SocketException('sem rede');
      await store.restore();
      api.error = null;

      expect(await store.accessToken(), 'access-2');
    });

    test('pedidos juntos: um refresh só', () async {
      await store.login('ana@example.com', 'x');
      api.hold = Completer<void>();

      final tokens = Future.wait([
        store.accessToken(renew: true),
        store.accessToken(renew: true),
      ]);
      api.hold!.complete();

      expect(await tokens, ['access-2', 'access-2']);
      expect(
        api.routes.where((r) => r == 'POST /tokens/refresh'),
        hasLength(1),
      );
    });

    test('refresh recusado: desloga e devolve null', () async {
      await store.login('ana@example.com', 'x');
      api.responses['POST /tokens/refresh'] = FakeAuthApi.errors({
        'refresh_token': 'Inválido.',
      });

      expect(await store.accessToken(renew: true), isNull);
      expect((store.isSignedIn, storage.token), (false, null));
      expect(store.sessionExpired, isTrue);

      await store.login('ana@example.com', 'x');
      expect(store.sessionExpired, isFalse);
    });

    test('sair por conta própria não marca sessão expirada', () async {
      await store.login('ana@example.com', 'x');

      await store.logout();

      expect(store.sessionExpired, isFalse);
    });
  });
}
