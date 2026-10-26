import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'package:tagarela/data/device/social_sign_in.dart';

class FakeGooglePlatform extends GoogleSignInPlatform {
  final inits = <String?>[];

  @override
  Future<void> init(InitParameters params) async =>
      inits.add(params.serverClientId);

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) async => const AuthenticationResults(
    user: GoogleSignInUserData(email: 'ana@example.com', id: '1'),
    authenticationTokens: AuthenticationTokenData(idToken: 'google-id-token'),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeGooglePlatform platform;
  late SocialSignIn social;

  setUp(() {
    platform = FakeGooglePlatform();
    GoogleSignInPlatform.instance = platform;
    social = SocialSignIn();
  });

  test('Google inicia uma vez e devolve o token com o client ID', () async {
    final token = await social.google('web-1');
    await social.google('web-1');

    expect(platform.inits, ['web-1']);
    expect(
      (token?.provider, token?.clientId, token?.idToken),
      ('google', 'web-1', 'google-id-token'),
    );
  });

  test('client ID novo da API reinicia o Google', () async {
    await social.google('android-errado');
    final token = await social.google('web-certo');

    expect(platform.inits, ['android-errado', 'web-certo']);
    expect(token?.clientId, 'web-certo');
  });
}
