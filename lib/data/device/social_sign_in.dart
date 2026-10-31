import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialToken {
  const SocialToken({
    required this.provider,
    required this.clientId,
    required this.idToken,
  });

  final String provider;
  final String clientId;
  final String idToken;
}

class SocialSignIn {
  SocialSignIn({
    required String googleIosClientId,
    required String appleClientId,
  }) : _googleIosClientId = googleIosClientId,
       _appleClientId = appleClientId;

  final String _googleIosClientId;
  final String _appleClientId;

  String? _googleClientId;

  Future<SocialToken?> google(String serverClientId) async {
    final google = GoogleSignIn.instance;
    if (_googleClientId != serverClientId) {
      await google.initialize(
        clientId: _googleIosClientId.isEmpty ? null : _googleIosClientId,
        serverClientId: serverClientId,
      );
      _googleClientId = serverClientId;
    }
    try {
      final idToken = (await google.authenticate()).authentication.idToken;
      if (idToken == null) return null;
      return SocialToken(
        provider: 'google',
        clientId: serverClientId,
        idToken: idToken,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<SocialToken?> apple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = credential.identityToken;
      if (idToken == null) return null;
      return SocialToken(
        provider: 'apple',
        clientId: _appleClientId,
        idToken: idToken,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}
