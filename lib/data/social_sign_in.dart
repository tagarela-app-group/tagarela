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
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
  static const appleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: 'com.tagarela.tagarela',
  );

  String? _googleClientId;

  Future<SocialToken?> google(String serverClientId) async {
    final google = GoogleSignIn.instance;
    if (_googleClientId != serverClientId) {
      await google.initialize(
        clientId: googleIosClientId.isEmpty ? null : googleIosClientId,
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
        clientId: appleClientId,
        idToken: idToken,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}
