import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('bandeira redonda do país, com anel e nome pra leitor', (
    tester,
  ) async {
    await tester.pumpComponent(
      const FlagBadge(
        country: 'BR',
        size: 30,
        ring: AppPalette.white,
        semanticLabel: 'Bandeira: Brasil',
      ),
    );

    final flag = tester.widget<CountryFlag>(find.byType(CountryFlag));
    expect(flag.flagCode, 'br');
    expect(tester.getSize(find.byType(FlagBadge)), const Size(30, 30));
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(FlagBadge),
        matching: find.byType(Container),
      ),
    );
    expect((box.decoration! as BoxDecoration).color, AppPalette.white);
    expect(find.bySemanticsLabel('Bandeira: Brasil'), findsOneWidget);
  });
}
