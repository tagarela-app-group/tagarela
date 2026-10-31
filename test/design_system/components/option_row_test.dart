import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('em lista de escolha: check na escolhida, nada nas outras', (
    tester,
  ) async {
    await tester.pumpComponent(
      Column(
        children: [
          OptionRow(
            icon: AppIcons.language,
            accent: AppAccent.sky,
            title: 'English',
            selected: true,
            onTap: () {},
          ),
          OptionRow(
            icon: AppIcons.language,
            accent: AppAccent.sky,
            title: 'Español',
            selected: false,
            onTap: () {},
          ),
        ],
      ),
    );

    expect(find.byIcon(AppIcons.check), findsOneWidget);
    expect(find.byIcon(AppIcons.forward), findsNothing);
    expect(
      tester.getSemantics(find.text('English')),
      isSemantics(isSelected: true, isInMutuallyExclusiveGroup: true),
    );
    expect(
      tester.getSemantics(find.text('Español')),
      isSemantics(isSelected: false, isInMutuallyExclusiveGroup: true),
    );
  });
}
