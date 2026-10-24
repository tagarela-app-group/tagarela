import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

final _icons = [
  for (var i = 0; i < 26; i++) (icon: AppIcons.travel, label: 'Ícone $i'),
];

void main() {
  Future<List<int>> pump(WidgetTester tester, {int selected = 0}) async {
    final picked = <int>[];
    await tester.pumpComponent(
      StatefulBuilder(
        builder: (context, setState) => IconPicker(
          icons: _icons,
          selected: selected,
          accent: AppAccent.sky,
          onChanged: (i) => setState(() {
            picked.add(i);
            selected = i;
          }),
        ),
      ),
    );
    return picked;
  }

  bool checked(WidgetTester tester, String label) => isSemantics(
    isChecked: true,
  ).matches(tester.getSemantics(find.bySemanticsLabel(label)), {});

  testWidgets('12 por página, com a página atual', (tester) async {
    await pump(tester);

    expect(find.text('Ícone'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.bySemanticsLabel('Ícone 11'), findsOneWidget);
    expect(find.bySemanticsLabel('Ícone 12'), findsNothing);
    expect(find.text('Voltar'), findsNothing);
  });

  testWidgets('Avançar e Voltar trocam a página; na última some o Avançar', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Avançar'));
    await tester.pump();
    expect(find.text('2/3'), findsOneWidget);
    expect(find.bySemanticsLabel('Ícone 12'), findsOneWidget);

    await tester.tap(find.text('Avançar'));
    await tester.pump();
    expect(find.text('3/3'), findsOneWidget);
    expect(find.bySemanticsLabel('Ícone 25'), findsOneWidget);
    expect(tester.widget<Visibility>(find.byType(Visibility)).visible, isFalse);

    await tester.tap(find.text('Voltar'));
    await tester.pump();
    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('abre na página do ícone escolhido', (tester) async {
    await pump(tester, selected: 14);

    expect(find.text('2/3'), findsOneWidget);
    expect(checked(tester, 'Ícone 14'), isTrue);
  });

  testWidgets('toque escolhe o ícone', (tester) async {
    final picked = await pump(tester);
    expect(checked(tester, 'Ícone 0'), isTrue);

    await tester.tap(find.bySemanticsLabel('Ícone 3'));
    await tester.pump();

    expect(picked, [3]);
    expect(checked(tester, 'Ícone 3'), isTrue);
    expect(checked(tester, 'Ícone 0'), isFalse);
  });
}
