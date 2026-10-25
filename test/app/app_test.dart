import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/features/auth/login_page.dart';

import '../helpers/fake_preferences.dart';
import '../helpers/pump_app.dart';

void main() {
  Future<LanguageStore> pumpApp(
    WidgetTester tester, {
    String? saved,
    List<Locale> device = const [Locale('pt', 'BR')],
  }) async {
    tester.useTallScreen();
    tester.platformDispatcher.localesTestValue = device;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final language = fakeLanguage(saved);
    await tester.pumpWidget(
      testScope(language: language, child: const TagarelaApp()),
    );
    await tester.pumpAndSettle();
    return language;
  }

  testWidgets('app sem sessão abre no login', (tester) async {
    await pumpApp(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);
  });

  testWidgets('sem escolha segue o idioma do aparelho', (tester) async {
    await pumpApp(tester, device: const [Locale('es', 'AR')]);

    expect(find.text('Continuar con Google'), findsOneWidget);
  });

  testWidgets('aparelho em idioma que o app não tem abre em inglês', (
    tester,
  ) async {
    await pumpApp(tester, device: const [Locale('fr', 'FR')]);

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('escolha salva vence o aparelho e troca na hora', (tester) async {
    final language = await pumpApp(tester, saved: 'en');
    expect(find.text('Continue with Google'), findsOneWidget);

    await language.choose(AppLanguage.es);
    await tester.pumpAndSettle();
    expect(find.text('Continuar con Google'), findsOneWidget);

    await language.choose(null);
    await tester.pumpAndSettle();
    expect(find.text('Continuar com Google'), findsOneWidget);
  });
}
