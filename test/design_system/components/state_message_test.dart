import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra ícone, título e texto; sem ação', (tester) async {
    await tester.pumpComponent(
      const StateMessage(
        icon: AppIcons.inbox,
        title: 'Inbox zerado',
        message: 'Use o +.',
      ),
    );

    expect(find.byIcon(AppIcons.inbox), findsOneWidget);
    expect(find.text('Inbox zerado'), findsOneWidget);
    expect(find.text('Use o +.'), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('glyph no lugar do ícone e ícone na ação', (tester) async {
    await tester.pumpComponent(
      StateMessage(
        glyph: const DrawnIcon(DrawnGlyph.bubble),
        title: 'Comece',
        message: 'Capture.',
        actionLabel: 'Capturar',
        actionIcon: AppIcons.add,
        onAction: () {},
      ),
    );

    expect(drawnIcon(DrawnGlyph.bubble), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppButton),
        matching: find.byIcon(AppIcons.add),
      ),
      findsOneWidget,
    );
  });

  testWidgets('ação chama onAction', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      StateMessage(
        icon: AppIcons.offline,
        title: 'Erro',
        message: 'Tente de novo.',
        actionLabel: 'Tentar',
        onAction: () => taps++,
      ),
    );

    await tester.tap(find.text('Tentar'));
    expect(taps, 1);
  });
}
