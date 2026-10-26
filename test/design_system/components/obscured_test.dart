import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  ImageFiltered filter(WidgetTester tester) =>
      tester.widget<ImageFiltered>(find.byType(ImageFiltered));

  double opacity(WidgetTester tester) =>
      tester.widget<Opacity>(find.byType(Opacity)).opacity;

  Future<void> pump(WidgetTester tester, {required bool obscured}) =>
      tester.pumpComponent(
        Obscured(obscured: obscured, child: const Text('segredo')),
      );

  testWidgets('obscurecido: desfoca, apaga e esconde da leitura', (
    tester,
  ) async {
    await pump(tester, obscured: true);

    expect(filter(tester).enabled, isTrue);
    expect(opacity(tester), AppOpacity.obscured);
    expect(find.bySemanticsLabel('segredo'), findsNothing);
  });

  testWidgets('revelar tira o desfoque aos poucos e volta a leitura', (
    tester,
  ) async {
    await pump(tester, obscured: true);
    await pump(tester, obscured: false);

    await tester.pump(AppMotion.reveal ~/ 4);
    expect(filter(tester).enabled, isTrue);
    expect(
      opacity(tester),
      allOf(greaterThan(AppOpacity.obscured), lessThan(1)),
    );

    await tester.pumpAndSettle();
    expect(filter(tester).enabled, isFalse);
    expect(opacity(tester), 1);
    expect(find.bySemanticsLabel('segredo'), findsOneWidget);
  });

  testWidgets('reduzir movimento revela na hora', (tester) async {
    Future<void> pumpStill({required bool obscured}) => tester.pumpComponent(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Obscured(obscured: obscured, child: const Text('segredo')),
      ),
    );

    await pumpStill(obscured: true);
    await pumpStill(obscured: false);
    await tester.pump();

    expect(filter(tester).enabled, isFalse);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
