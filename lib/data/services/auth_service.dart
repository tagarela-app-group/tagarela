import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/social_sign_in.dart';

enum AuthStep {
  verifyEmail('verify_email'),
  resetPassword('password_reset_by_code');

  const AuthStep(this.flow);

  final String flow;
}

sealed class AuthResult {
  const AuthResult();
}

class AuthSignedIn extends AuthResult {
  const AuthSignedIn(this.tokens);

  final AuthTokens tokens;
}

class AuthPending extends AuthResult {
  const AuthPending(this.step, this.sessionToken);

  final AuthStep step;
  final String sessionToken;
}

class AuthException implements Exception {
  const AuthException(this.errors);

  AuthException.message(String message) : this({null: message});

  final Map<String?, String> errors;

  String? get message => errors[null];

  @override
  String toString() => 'AuthException: $errors';
}

class AuthService {
  const AuthService(this._api);

  static const _base = '/api/auth/app/v1';

  final ApiClient _api;

  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  }) => _auth(
    '/auth/signup',
    body: {'name': name, 'email': email, 'password': password},
  );

  Future<AuthResult> login({required String email, required String password}) =>
      _auth('/auth/login', body: {'email': email, 'password': password});

  Future<AuthResult> verifyEmail(String code, {required String sessionToken}) =>
      _auth(
        '/auth/email/verify',
        body: {'key': code},
        sessionToken: sessionToken,
      );

  Future<void> resendEmailCode({required String sessionToken}) async {
    _check(
      await _call(
        'POST',
        '/auth/email/verify/resend',
        sessionToken: sessionToken,
      ),
    );
  }

  Future<AuthResult> requestPasswordReset(String email) =>
      _auth('/auth/password/request', body: {'email': email});

  Future<void> checkResetCode(
    String code, {
    required String sessionToken,
  }) async {
    _check(
      await _call(
        'GET',
        '/auth/password/reset',
        sessionToken: sessionToken,
        headers: {'X-Password-Reset-Key': code},
      ),
    );
  }

  Future<AuthResult> resetPassword(
    String code,
    String password, {
    required String sessionToken,
  }) => _auth(
    '/auth/password/reset',
    body: {'key': code, 'password': password},
    sessionToken: sessionToken,
  );

  Future<AuthResult> signInWithProvider(SocialToken token) => _auth(
    '/auth/provider/token',
    body: {
      'provider': token.provider,
      'process': 'login',
      'token': {'client_id': token.clientId, 'id_token': token.idToken},
    },
  );

  Future<String> providerClientId(String provider) async {
    final response = _check(await _call('GET', '/config'));
    final data = (response.body! as Json)['data']! as Json;
    final providers = (data['socialaccount'] as Json?)?['providers'] as List?;
    final clientId = providers
        ?.cast<Json>()
        .where((p) => p['id'] == provider)
        .map((p) => p['client_id'])
        .firstOrNull;
    if (clientId is String && clientId.isNotEmpty) return clientId;
    throw AuthException.message('Esse login não está disponível agora.');
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final response = _check(
      await _call(
        'POST',
        '/tokens/refresh',
        body: {'refresh_token': refreshToken},
      ),
    );
    return AuthTokens.fromJson((response.body! as Json)['data']! as Json);
  }

  Future<void> logout(String accessToken) => _call(
    'DELETE',
    '/auth/session',
    headers: {'Authorization': 'Bearer $accessToken'},
  );

  Future<AuthResult> _auth(
    String path, {
    required Json body,
    String? sessionToken,
  }) async {
    final response = await _call(
      'POST',
      path,
      body: body,
      sessionToken: sessionToken,
    );
    final json = response.body as Json?;
    final meta = json?['meta'] as Json?;
    if (response.statusCode == 200) {
      return AuthSignedIn(AuthTokens.fromJson(meta!));
    }
    final step = _pendingStep(json);
    if (response.statusCode == 401 && step != null) {
      return AuthPending(step, meta!['session_token']! as String);
    }
    throw _error(response);
  }

  Future<ApiResponse> _call(
    String method,
    String path, {
    Object? body,
    String? sessionToken,
    Map<String, String> headers = const {},
  }) => _api.send(
    method,
    '$_base$path',
    body: body,
    headers: {...headers, 'X-Session-Token': ?sessionToken},
  );

  static ApiResponse _check(ApiResponse response) {
    if (response.statusCode == 200) return response;
    throw _error(response);
  }

  static AuthStep? _pendingStep(Json? json) {
    final flows = (json?['data'] as Json?)?['flows'] as List?;
    final pending = flows
        ?.cast<Json>()
        .where((flow) => flow['is_pending'] == true)
        .map((flow) => flow['id'])
        .firstOrNull;
    return AuthStep.values.where((step) => step.flow == pending).firstOrNull;
  }

  static Exception _error(ApiResponse response) {
    final status = response.statusCode;
    if (status >= 500) return ApiException(status, 'auth');
    if (status == 429) {
      return AuthException.message(
        'Muitas tentativas. Espere um pouco e tente de novo.',
      );
    }
    if (status == 409 || status == 410) {
      return AuthException.message('Essa etapa expirou. Comece de novo.');
    }
    final errors = ((response.body as Json?)?['errors'] as List?)?.cast<Json>();
    if (errors == null || errors.isEmpty) {
      return AuthException.message('Não deu certo. Tente de novo.');
    }
    return AuthException({
      for (final error in errors.reversed)
        error['param'] as String?: error['message']! as String,
    });
  }
}
