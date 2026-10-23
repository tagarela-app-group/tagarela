import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/services/auth_service.dart';
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

  group('restore', () {
    test('sem token salvo: deslogado, sem chamar a API', () async {
      expect(await store.restore(), isFalse);
      expect(api.requests, isEmpty);
    });

    test('token válido: logado e guarda o refresh novo', () async {
      storage.token = 'refresh-1';

      expect(await store.restore(), isTrue);
      expect(store.isSignedIn, isTrue);
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

    test('sem rede: entra com o token salvo', () async {
      storage.token = 'refresh-1';
      api.error = const SocketException('offline');

      expect(await store.restore(), isTrue);
      expect(storage.token, 'refresh-1');
    });
  });

  test('login salva o refresh token e avisa', () async {
    var notified = 0;
    store.addListener(() => notified++);

    final result = await store.login('ana@example.com', 'x');

    expect(result, isA<AuthSignedIn>());
    expect((store.isSignedIn, storage.token, notified), (true, 'refresh-1', 1));
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

  test('login social cancelado devolve null sem chamar a API', () async {
    social.googleToken = null;

    expect(await store.signInWithGoogle(), isNull);
    expect(api.requests, isEmpty);
  });

  test('logout apaga o token e encerra a sessão na API', () async {
    await store.login('ana@example.com', 'x');

    await store.logout();

    expect((store.isSignedIn, storage.token), (false, null));
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
}
