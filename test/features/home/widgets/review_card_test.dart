import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/home/widgets/review_card.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra quantidade e chama onStart', (tester) async {
    var taps = 0;
    await tester.pumpComponent(ReviewCard(count: 7, onStart: () => taps++));

    expect(find.text('7 termos'), findsOneWidget);
    await tester.tap(find.text('Começar'));
    expect(taps, 1);
  });
}
