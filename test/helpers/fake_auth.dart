import 'dart:async';

import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/data/social_sign_in.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/token_storage.dart';

typedef FakeRequest = ({
  String route,
  Object? body,
  Map<String, String> headers,
});

class FakeAuthApi implements ApiClient {
  static const prefix = '/api/auth/app/v1';

  final requests = <FakeRequest>[];

  final responses = <String, ApiResponse>{
    'POST /auth/login': signedIn(),
    'POST /auth/signup': pending('verify_email'),
    'POST /auth/email/verify': signedIn(),
    'POST /auth/email/verify/resend': const ApiResponse(200, {'status': 200}),
    'POST /auth/password/request': pending('password_reset_by_code'),
    'GET /auth/password/reset': const ApiResponse(200, {'status': 200}),
    'POST /auth/password/reset': signedIn(),
    'POST /auth/provider/token': signedIn(),
    'POST /tokens/refresh': const ApiResponse(200, {
      'status': 200,
      'data': {'access_token': 'access-2', 'refresh_token': 'refresh-2'},
    }),
    'GET /auth/session': const ApiResponse(200, {
      'status': 200,
      'data': {'user': user},
      'meta': {'is_authenticated': true},
    }),
    'DELETE /auth/session': const ApiResponse(401, {'status': 401}),
    'GET /config': config({'google': 'web-client-id'}),
  };

  Exception? error;
  Completer<void>? hold;

  List<String> get routes => [for (final r in requests) r.route];

  FakeRequest last(String route) => requests.lastWhere((r) => r.route == route);

  static const user = {
    'id': 1,
    'email': 'ana@example.com',
    'display': 'Ana Souza',
    'name': 'Ana Souza',
    'picture': 'https://example.com/ana.png',
  };

  static ApiResponse signedIn([String refresh = 'refresh-1']) =>
      ApiResponse(200, {
        'status': 200,
        'data': {'user': user},
        'meta': {
          'is_authenticated': true,
          'access_token': 'access-1',
          'refresh_token': refresh,
        },
      });

  static ApiResponse pending(String flow, [String session = 'session-1']) =>
      ApiResponse(401, {
        'status': 401,
        'data': {
          'flows': [
            {'id': 'login'},
            {'id': flow, 'is_pending': true},
          ],
        },
        'meta': {'is_authenticated': false, 'session_token': session},
      });

  static ApiResponse config(Map<String, String> clientIds) => ApiResponse(200, {
    'status': 200,
    'data': {
      'socialaccount': {
        'providers': [
          for (final MapEntry(:key, :value) in clientIds.entries)
            {'id': key, 'name': key, 'client_id': value},
        ],
      },
    },
  });

  static ApiResponse errors(Map<String?, String> messages) => ApiResponse(400, {
    'status': 400,
    'errors': [
      for (final MapEntry(:key, :value) in messages.entries)
        {'message': value, 'code': 'invalid', 'param': ?key},
    ],
  });

  @override
  String get baseUrl => 'fake-auth://';

  @override
  AccessToken? get accessToken => null;

  @override
  Future<ApiResponse> send(
    String method,
    String path, {
    Object? body,
    Map<String, String> headers = const {},
  }) async {
    final route = '$method ${path.replaceFirst(prefix, '')}';
    requests.add((route: route, body: body, headers: headers));
    if (hold case final hold?) await hold.future;
    if (error case final error?) throw error;
    return responses[route] ?? (throw StateError('sem resposta pra $route'));
  }

  @override
  Future<Object?> get(String path) => throw UnimplementedError();

  @override
  Future<Object?> post(String path, Map<String, Object?> body) =>
      throw UnimplementedError();

  @override
  Future<Object?> patch(String path, Map<String, Object?> body) =>
      throw UnimplementedError();

  @override
  Future<Object?> delete(String path) => throw UnimplementedError();
}

class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage([this.token, this.user]);

  String? token;
  User? user;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;

  @override
  Future<User?> readUser() async => user;

  @override
  Future<void> writeUser(User user) async => this.user = user;

  @override
  Future<void> clear() async {
    token = null;
    user = null;
  }
}

class FakeSocialSignIn implements SocialSignIn {
  SocialToken? googleToken = const SocialToken(
    provider: 'google',
    clientId: 'web-client-id',
    idToken: 'google-id-token',
  );
  SocialToken? appleToken = const SocialToken(
    provider: 'apple',
    clientId: 'com.tagarela.tagarela',
    idToken: 'apple-id-token',
  );
  Exception? error;
  String? googleClientId;

  @override
  Future<SocialToken?> google(String serverClientId) async {
    googleClientId = serverClientId;
    if (error case final error?) throw error;
    return googleToken;
  }

  @override
  Future<SocialToken?> apple() async {
    if (error case final error?) throw error;
    return appleToken;
  }
}

AuthStore fakeAuthStore({
  FakeAuthApi? api,
  FakeTokenStorage? storage,
  FakeSocialSignIn? social,
}) => AuthStore(
  AuthService(api ?? FakeAuthApi()),
  storage ?? FakeTokenStorage(),
  social ?? FakeSocialSignIn(),
);

Future<AuthStore> signedInAuthStore({
  FakeAuthApi? api,
  FakeTokenStorage? storage,
}) async {
  final auth = fakeAuthStore(api: api, storage: storage);
  await auth.login('ana@example.com', 'x');
  return auth;
}
