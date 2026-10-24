import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/home/home_page.dart';
import 'package:tagarela/features/inbox/inbox_page.dart';
import 'package:tagarela/features/profile/profile_page.dart';
import 'package:tagarela/features/vocabulary/vocabulary_page.dart';

import '../helpers/fake_vocabulary_api.dart';
import '../helpers/fake_auth.dart';
import '../helpers/fake_capture_store.dart';
import '../helpers/pump_app.dart';

int _currentTab(WidgetTester tester) => const [
  HomePage,
  VocabularyPage,
  InboxPage,
  ProfilePage,
].indexWhere((page) => tester.any(find.byType(page)));

Finder _tab(String label) =>
    find.descendant(of: find.byType(AppTabBar), matching: find.text(label));

Finder _inMenu(IconData icon) =>
    find.descendant(of: find.byType(ArcMenu), matching: find.byIcon(icon));

void main() {
  testWidgets('abre na aba Início', (tester) async {
    await tester.pumpPage(const HomeShell());

    expect(_currentTab(tester), 0);
  });

  testWidgets('tab bar troca de aba', (tester) async {
    await tester.pumpPage(const HomeShell());

    for (final (label, index) in const [
      ('Vocabulário', 1),
      ('Inbox', 2),
      ('Perfil', 3),
      ('Início', 0),
    ]) {
      await tester.tap(_tab(label));
      await tester.pumpAndSettle();
      expect(_currentTab(tester), index, reason: label);
    }
  });

  testWidgets('aba nova entra com fade por cima da antiga', (tester) async {
    await tester.pumpPage(const HomeShell());
    double opacity() => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byType(VocabularyPage),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    await tester.tap(_tab('Vocabulário'));
    await tester.pump();
    await tester.pump(AppMotion.slow ~/ 4);
    expect(opacity(), inExclusiveRange(0, 1));
    expect(find.byType(HomePage), findsOneWidget);

    await tester.pumpAndSettle();
    expect(opacity(), 1);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('badge do Inbox conta prontas e com erro', (tester) async {
    final captures = fakeCaptures();
    for (final (id, status) in [
      ('a', CaptureStatus.ready),
      ('b', CaptureStatus.failed),
      ('c', CaptureStatus.processing),
    ]) {
      await captures.db.saveCapture(
        'ana@example.com',
        sampleCapture(id, status: status),
      );
    }
    await tester.pumpPage(const HomeShell(), captures: captures.store);
    Finder badge(int n) =>
        find.descendant(of: find.byType(AppTabBar), matching: find.text('$n'));
    expect(badge(2), findsOneWidget);

    await tester.tap(_tab('Inbox'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar').first);
    await tester.pumpAndSettle();

    expect(badge(1), findsOneWidget);
  });

  testWidgets('sessão expirada volta pro login com aviso', (tester) async {
    final api = FakeAuthApi();
    final auth = await signedInAuthStore(api: api);
    await tester.pumpPage(const HomeShell(), auth: auth);
    api.responses['POST /tokens/refresh'] = FakeAuthApi.errors({
      'refresh_token': 'Inválido.',
    });

    await auth.accessToken(renew: true);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Sua sessão expirou. Entre de novo.'), findsOneWidget);
  });

  testWidgets('sair pelo Perfil não mostra aviso de sessão', (tester) async {
    final auth = await signedInAuthStore();
    await tester.pumpPage(const HomeShell(), auth: auth);

    await auth.logout();
    await tester.pumpAndSettle();

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.text('Sua sessão expirou. Entre de novo.'), findsNothing);
  });

  testWidgets('Início vazia: "Fazer a primeira captura" abre o menu +', (
    tester,
  ) async {
    await tester.pumpPage(
      const HomeShell(),
      home: HomeStore(),
      vocabulary: emptyVocabulary(),
    );
    expect(find.text('O que você ouviu hoje?'), findsNothing);

    await tester.tap(find.text('Fazer a primeira captura'));
    await tester.pumpAndSettle();

    expect(find.text('O que você ouviu hoje?'), findsOneWidget);
    expect(_inMenu(AppIcons.camera), findsOneWidget);
  });

  testWidgets('"Ver tudo" da Início abre Vocabulário', (tester) async {
    await tester.pumpPage(const HomeShell());

    await tester.tap(find.text('Ver tudo'));
    await tester.pumpAndSettle();

    expect(_currentTab(tester), 1);
  });

  Future<void> openFromMenu(WidgetTester tester, IconData icon) async {
    await tester.tap(find.bySemanticsLabel('Adicionar termo'));
    await tester.pumpAndSettle();
    expect(find.text('O que você ouviu hoje?'), findsOneWidget);
    await tester.tap(_inMenu(icon));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('+ abre a captura de cada tipo', (tester) async {
    await tester.pumpPage(const HomeShell());

    for (final (icon, title) in const [
      (AppIcons.camera, 'Foto'),
      (AppIcons.audio, 'Gravando…'),
      (AppIcons.text, 'Digitar texto'),
    ]) {
      await openFromMenu(tester, icon);
      expect(find.byType(AppSheet), findsOneWidget, reason: title);
      expect(find.text(title), findsOneWidget);
      expect(find.text('O que você ouviu hoje?'), findsNothing);

      await tester.tap(find.byTooltip('Fechar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AppSheet), findsNothing);
      expect(_currentTab(tester), 0);
    }
  });

  testWidgets('salvar avisa e Ver abre o Inbox', (tester) async {
    await tester.pumpPage(const HomeShell());

    await openFromMenu(tester, AppIcons.text);
    await tester.enterText(find.byType(TextField), 'mind the gap');
    await tester.pump();
    await tester.tap(find.text('Salvar no Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Salvo no Inbox'), findsOneWidget);
    expect(find.text('Pronto pra escolher os termos.'), findsOneWidget);

    await tester.tap(find.text('Ver'));
    await tester.pumpAndSettle();

    expect(_currentTab(tester), 2);
    expect(find.text('mind the gap'), findsOneWidget);
  });
}
