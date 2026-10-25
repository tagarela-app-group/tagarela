import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra ícone, título, subtítulo e seta; toque chama onTap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpComponent(
      OptionRow(
        icon: AppIcons.camera,
        accent: AppAccent.mango,
        title: 'Tirar foto',
        subtitle: 'Abre a câmera do celular',
        onTap: () => taps++,
      ),
    );

    expect(find.text('Tirar foto'), findsOneWidget);
    expect(find.text('Abre a câmera do celular'), findsOneWidget);
    expect(find.byIcon(AppIcons.camera), findsOneWidget);
    expect(find.byIcon(AppIcons.forward), findsOneWidget);

    await tester.tap(find.text('Tirar foto'));
    expect(taps, 1);
  });

  testWidgets('tracejada, sem subtítulo e com fim próprio', (tester) async {
    await tester.pumpComponent(
      OptionRow(
        icon: AppIcons.add,
        accent: AppAccent.violet,
        title: 'Novo grupo',
        dashed: true,
        trailing: const Text('Organizar'),
        onTap: () {},
      ),
    );

    expect(find.text('Novo grupo'), findsOneWidget);
    expect(find.text('Organizar'), findsOneWidget);
    expect(find.byIcon(AppIcons.forward), findsNothing);
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(OptionRow),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.shape, isNot(isA<RoundedRectangleBorder>()));
  });

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

  testWidgets('leading próprio no lugar do ícone', (tester) async {
    await tester.pumpComponent(
      OptionRow(
        leading: const SizedBox.square(key: Key('flag'), dimension: 40),
        title: 'Brasil',
        onTap: () {},
      ),
    );

    expect(find.byKey(const Key('flag')), findsOneWidget);
    expect(find.byType(IconTile), findsNothing);
  });
}
