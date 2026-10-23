import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app.dart';
import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/features/auth/login_page.dart';

import '../helpers/fake_api_client.dart';
import '../helpers/fake_auth.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('app sem sessão abre no login', (tester) async {
    tester.useTallScreen();
    await tester.pumpWidget(
      AppScope(
        api: FakeApiClient(),
        auth: fakeAuthStore(),
        child: const TagarelaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
