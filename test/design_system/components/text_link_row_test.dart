import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra o texto e o link, que chama a ação', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      TextLinkRow(
        text: 'Novo aqui?',
        link: 'Criar conta',
        onPressed: () => taps++,
      ),
    );

    expect(find.text('Novo aqui?'), findsOneWidget);
    await tester.tap(find.text('Criar conta'));
    expect(taps, 1);
  });
}
