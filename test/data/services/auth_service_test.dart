import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/data/social_sign_in.dart';

import '../../helpers/fake_auth.dart';

void main() {
  late FakeAuthApi api;
  late AuthService service;

  setUp(() {
    api = FakeAuthApi();
    service = AuthService(api);
  });

  test('login 200 devolve tokens e manda e-mail e senha', () async {
    final result = await service.login(email: 'ana@example.com', password: 'x');

    expect(result, isA<AuthSignedIn>());
    final tokens = (result as AuthSignedIn).tokens;
    expect((tokens.access, tokens.refresh), ('access-1', 'refresh-1'));
    expect(
      (result.user?.name, result.user?.picture),
      ('Ana Souza', 'https://example.com/ana.png'),
    );
    expect(api.last('POST /auth/login').body, {
      'email': 'ana@example.com',
      'password': 'x',
    });
  });

  test(
    'cadastro 401 com verify_email pendente devolve etapa e token',
    () async {
      final result = await service.signup(
        name: 'Ana',
        email: 'ana@example.com',
        password: 'x',
      );

      expect(result, isA<AuthPending>());
      final pending = result as AuthPending;
      expect(
        (pending.step, pending.sessionToken),
        (AuthStep.verifyEmail, 'session-1'),
      );
      expect(api.last('POST /auth/signup').body, {
        'name': 'Ana',
        'email': 'ana@example.com',
        'password': 'x',
      });
    },
  );

  test('pedido de reset devolve etapa de reset', () async {
    final result = await service.requestPasswordReset('ana@example.com');

    expect((result as AuthPending).step, AuthStep.resetPassword);
  });

  test('etapas pendentes mandam X-Session-Token', () async {
    await service.verifyEmail('123456', sessionToken: 'session-1');
    await service.resendEmailCode(sessionToken: 'session-1');
    await service.resetPassword('123456', 'nova', sessionToken: 'session-1');

    for (final route in [
      'POST /auth/email/verify',
      'POST /auth/email/verify/resend',
      'POST /auth/password/reset',
    ]) {
      expect(api.last(route).headers['X-Session-Token'], 'session-1');
    }
    expect(api.last('POST /auth/email/verify').body, {'key': '123456'});
    expect(api.last('POST /auth/password/reset').body, {
      'key': '123456',
      'password': 'nova',
    });
  });

  test('validar código manda X-Password-Reset-Key', () async {
    await service.checkResetCode('123456', sessionToken: 'session-1');

    expect(api.last('GET /auth/password/reset').headers, {
      'X-Password-Reset-Key': '123456',
      'X-Session-Token': 'session-1',
    });
  });

  test('login social manda provider, client_id e id_token', () async {
    await service.signInWithProvider(
      const SocialToken(provider: 'google', clientId: 'web', idToken: 'tok'),
    );

    expect(api.last('POST /auth/provider/token').body, {
      'provider': 'google',
      'process': 'login',
      'token': {'client_id': 'web', 'id_token': 'tok'},
    });
  });

  test('session manda Bearer e devolve o usuário', () async {
    final user = await service.session('access-9');

    expect((user.name, user.email), ('Ana Souza', 'ana@example.com'));
    expect(
      api.last('GET /auth/session').headers['Authorization'],
      'Bearer access-9',
    );
  });

  test('client_id do provider vem do /config da API', () async {
    expect(await service.providerClientId('google'), 'web-client-id');
  });

  test('provider fora do /config vira AuthException', () async {
    api.responses['GET /config'] = FakeAuthApi.config({'google': ''});

    await expectLater(
      service.providerClientId('google'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.failure,
          'failure',
          AuthFailure.unavailable,
        ),
      ),
    );
    await expectLater(
      service.providerClientId('apple'),
      throwsA(isA<AuthException>()),
    );
  });

  test('refresh devolve novo par e logout manda Bearer', () async {
    final tokens = await service.refresh('refresh-1');
    await service.logout('access-2');

    expect((tokens.access, tokens.refresh), ('access-2', 'refresh-2'));
    expect(api.last('POST /tokens/refresh').body, {
      'refresh_token': 'refresh-1',
    });
    expect(
      api.last('DELETE /auth/session').headers['Authorization'],
      'Bearer access-2',
    );
  });

  test('400 vira AuthException com mensagem por campo, a 1ª vence', () async {
    api.responses['POST /auth/signup'] = const ApiResponse(400, {
      'errors': [
        {'message': 'Senha curta.', 'param': 'password'},
        {'message': 'Senha comum.', 'param': 'password'},
        {'message': 'Sem nome.', 'param': 'name'},
        {'message': 'Geral.'},
      ],
    });

    expect(
      service.signup(name: '', email: 'a@b.c', password: '1'),
      throwsA(
        isA<AuthException>().having((e) => e.errors, 'errors', {
          'password': 'Senha curta.',
          'name': 'Sem nome.',
          null: 'Geral.',
        }),
      ),
    );
  });

  test('429, 409 e 400 sem lista viram falha geral', () async {
    for (final (status, failure) in [
      (429, AuthFailure.tooManyAttempts),
      (409, AuthFailure.expired),
      (410, AuthFailure.expired),
      (400, AuthFailure.unknown),
    ]) {
      api.responses['POST /auth/login'] = ApiResponse(status, null);

      await expectLater(
        service.login(email: 'a@b.c', password: 'x'),
        throwsA(
          isA<AuthException>().having((e) => e.failure, 'failure', failure),
        ),
      );
    }
  });

  test('5xx vira ApiException', () async {
    api.responses['POST /tokens/refresh'] = const ApiResponse(502, null);

    expect(service.refresh('r'), throwsA(isA<ApiException>()));
  });

  test('401 sem etapa pendente vira AuthException', () async {
    api.responses['POST /auth/login'] = const ApiResponse(401, {
      'data': {'flows': <Object>[]},
    });

    expect(
      service.login(email: 'a@b.c', password: 'x'),
      throwsA(isA<AuthException>()),
    );
  });
}
