import 'package:flutter/foundation.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/data/social_sign_in.dart';
import 'package:tagarela/data/token_storage.dart';

class AuthStore extends ChangeNotifier {
  AuthStore(this._service, this._storage, this._social);

  final AuthService _service;
  final TokenStorage _storage;
  final SocialSignIn _social;

  String? _refreshToken;

  bool get isSignedIn => _refreshToken != null;

  Future<bool> restore() async {
    final stored = await _storage.read();
    if (stored == null) return false;
    _refreshToken = stored;
    try {
      await _save(await _service.refresh(stored));
    } on AuthException {
      await _forget();
    } on Exception {
      return true;
    }
    return isSignedIn;
  }

  Future<AuthResult> login(String email, String password) =>
      _signIn(_service.login(email: email, password: password));

  Future<AuthResult> signup(String name, String email, String password) =>
      _signIn(_service.signup(name: name, email: email, password: password));

  Future<AuthResult> verifyEmail(String code, String sessionToken) =>
      _signIn(_service.verifyEmail(code, sessionToken: sessionToken));

  Future<void> resendEmailCode(String sessionToken) =>
      _service.resendEmailCode(sessionToken: sessionToken);

  Future<AuthResult> requestPasswordReset(String email) =>
      _service.requestPasswordReset(email);

  Future<void> checkResetCode(String code, String sessionToken) =>
      _service.checkResetCode(code, sessionToken: sessionToken);

  Future<AuthResult> resetPassword(
    String code,
    String password,
    String sessionToken,
  ) => _signIn(
    _service.resetPassword(code, password, sessionToken: sessionToken),
  );

  Future<AuthResult?> signInWithGoogle() async {
    final clientId = await _service.providerClientId('google');
    return _signInWith(() => _social.google(clientId));
  }

  Future<AuthResult?> signInWithApple() => _signInWith(_social.apple);

  Future<void> logout() async {
    final refreshToken = _refreshToken;
    await _forget();
    if (refreshToken == null) return;
    try {
      await _service.logout((await _service.refresh(refreshToken)).access);
    } on Exception {
      return;
    }
  }

  Future<AuthResult?> _signInWith(
    Future<SocialToken?> Function() provider,
  ) async {
    final token = await provider();
    if (token == null) return null;
    return _signIn(_service.signInWithProvider(token));
  }

  Future<AuthResult> _signIn(Future<AuthResult> request) async {
    final result = await request;
    if (result is AuthSignedIn) await _save(result.tokens);
    return result;
  }

  Future<void> _save(AuthTokens tokens) async {
    _refreshToken = tokens.refresh;
    await _storage.write(tokens.refresh);
    notifyListeners();
  }

  Future<void> _forget() async {
    _refreshToken = null;
    await _storage.clear();
    notifyListeners();
  }
}
