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
}
