import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('rótulo em caixa alta, lido como cabeçalho', (tester) async {
    await tester.pumpComponent(const SectionLabel(label: 'Pra lembrar'));

    expect(find.text('PRA LEMBRAR'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('PRA LEMBRAR')),
      matchesSemantics(label: 'PRA LEMBRAR', isHeader: true),
    );
  });

  testWidgets('a ação entra e sai sem mudar a altura', (tester) async {
    await tester.pumpComponent(const SectionLabel(label: 'Significado'));
    final height = tester.getSize(find.byType(SectionLabel)).height;

    await tester.pumpComponent(
      SectionLabel(
        label: 'Significado',
        action: AppButton(
          label: 'Revelar',
          size: AppButtonSize.small,
          onPressed: () {},
        ),
      ),
    );

    expect(find.text('Revelar'), findsOneWidget);
    expect(tester.getSize(find.byType(SectionLabel)).height, height);
  });
}
