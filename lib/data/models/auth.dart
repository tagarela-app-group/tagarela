import 'package:tagarela/data/models/user.dart';

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
  const AuthSignedIn(this.tokens, [this.user]);

  final AuthTokens tokens;
  final User? user;
}

class AuthPending extends AuthResult {
  const AuthPending(this.step, this.sessionToken);

  final AuthStep step;
  final String sessionToken;
}

enum AuthFailure { unavailable, tooManyAttempts, expired, unknown }

class AuthException implements Exception {
  const AuthException(this.errors) : failure = null;

  const AuthException.failure(AuthFailure this.failure) : errors = const {};

  final Map<String?, String> errors;
  final AuthFailure? failure;

  @override
  String toString() => 'AuthException: ${failure ?? errors}';
}
