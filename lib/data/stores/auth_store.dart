import 'package:flutter/foundation.dart';

import 'package:tagarela/data/device/social_sign_in.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/account_service.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/data/storage/token_storage.dart';

class AuthStore extends ChangeNotifier {
  AuthStore(this._service, this._account, this._storage, this._social);

  final AuthService _service;
  final AccountService _account;
  final TokenStorage _storage;
  final SocialSignIn _social;

  String? _refreshToken;
  String? _accessToken;
  Future<void>? _renewing;
  bool _sessionExpired = false;
  User? _user;

  bool get isSignedIn => _refreshToken != null;

  bool get sessionExpired => _sessionExpired;

  User? get user => _user;

  Future<bool> restore() async {
    final stored = await _storage.read();
    if (stored == null) return false;
    _refreshToken = stored;
    _user = await _storage.readUser();
    try {
      final tokens = await _service.refresh(stored);
      await _save(tokens);
      await _saveUser(await _service.session(tokens.access));
    } on AuthException {
      await _forget();
    } on Exception {
      return true;
    }
    return isSignedIn;
  }

  Future<String?> accessToken({bool renew = false}) async {
    if (_refreshToken == null) return null;
    if (renew || _accessToken == null) {
      await (_renewing ??= _renew().whenComplete(() => _renewing = null));
    }
    return _accessToken;
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

  Future<void> updateCountry(String? country) async {
    if (!isSignedIn) return;
    await _saveUser(await _account.update(country: country ?? ''));
  }

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
    if (result is AuthSignedIn) {
      await _save(result.tokens);
      if (result.user case final user?) await _saveUser(user);
    }
    return result;
  }

  Future<void> _renew() async {
    try {
      await _save(await _service.refresh(_refreshToken!));
    } on AuthException {
      _sessionExpired = true;
      await _forget();
    }
  }

  Future<void> _save(AuthTokens tokens) async {
    _refreshToken = tokens.refresh;
    _accessToken = tokens.access;
    _sessionExpired = false;
    await _storage.write(tokens.refresh);
    notifyListeners();
  }

  Future<void> _saveUser(User user) async {
    _user = user;
    await _storage.writeUser(user);
    notifyListeners();
  }

  Future<void> _forget() async {
    _refreshToken = null;
    _accessToken = null;
    _user = null;
    await _storage.clear();
    notifyListeners();
  }
}
