import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('marcado mostra o check; desmarcado, só a borda', (tester) async {
    await tester.pumpComponent(const AppCheckbox(checked: true));
    expect(find.byIcon(AppIcons.check), findsOneWidget);

    await tester.pumpComponent(const AppCheckbox(checked: false));
    await tester.pumpAndSettle();
    expect(find.byIcon(AppIcons.check), findsNothing);
  });
}
