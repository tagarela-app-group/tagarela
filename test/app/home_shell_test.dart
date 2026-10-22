import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/design_system/design_system.dart';

import '../helpers/pump_app.dart';

int _currentTab(WidgetTester tester) =>
    tester.widget<IndexedStack>(find.byType(IndexedStack)).index!;

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

  testWidgets('badge do Inbox acompanha o store', (tester) async {
    final scope = await tester.pumpPage(const HomeShell());
    Finder badge(int n) =>
        find.descendant(of: find.byType(AppTabBar), matching: find.text('$n'));
    final count = scope.inbox.data!.length;
    expect(badge(count), findsOneWidget);

    await tester.tap(_tab('Inbox'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar').first);
    await tester.pump();

    expect(badge(count - 1), findsOneWidget);
  });

  testWidgets('"Ver tudo" da Início abre Vocabulário', (tester) async {
    await tester.pumpPage(const HomeShell());

    await tester.tap(find.text('Ver tudo'));
    await tester.pumpAndSettle();

    expect(_currentTab(tester), 1);
  });

  testWidgets('captura pelo + leva ao Inbox', (tester) async {
    await tester.pumpPage(const HomeShell());

    await tester.tap(_inMenu(AppIcons.add));
    await tester.pumpAndSettle();
    expect(find.text('O que você ouviu hoje?'), findsOneWidget);

    await tester.tap(_inMenu(AppIcons.camera));
    await tester.pumpAndSettle();

    expect(_currentTab(tester), 2);
    expect(find.text('O que você ouviu hoje?'), findsNothing);
  });
}
