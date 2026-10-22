import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('sem actionLabel não mostra botão', (tester) async {
    await tester.pumpComponent(const SectionHeader(title: 'Seus grupos'));

    expect(find.text('Seus grupos'), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('botão de ação chama onAction', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      SectionHeader(
        title: 'Seu vocabulário',
        actionLabel: 'Ver tudo',
        onAction: () => taps++,
      ),
    );

    await tester.tap(find.text('Ver tudo'));
    expect(taps, 1);
  });
}
