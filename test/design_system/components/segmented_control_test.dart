import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('toque devolve o índice da opção', (tester) async {
    int? changed;
    await tester.pumpComponent(
      SegmentedControl(
        options: const ['Todos', 'Aprendendo', 'Dominado'],
        selected: 0,
        onChanged: (i) => changed = i,
      ),
    );

    await tester.tap(find.text('Dominado'));
    expect(changed, 2);
  });

  testWidgets('marca só a opção selecionada', (tester) async {
    await tester.pumpComponent(
      SegmentedControl(
        options: const ['A', 'B'],
        selected: 1,
        onChanged: (_) {},
      ),
    );

    expect(
      tester.getSemantics(find.text('A')),
      isSemantics(isButton: true, isSelected: false),
    );
    expect(
      tester.getSemantics(find.text('B')),
      isSemantics(isButton: true, isSelected: true),
    );
  });

  testWidgets('indicador desliza suave até a opção nova', (tester) async {
    Widget control(int selected) => SegmentedControl(
      options: const ['A', 'B', 'C'],
      selected: selected,
      onChanged: (_) {},
    );
    final indicator = find.byType(AnimatedPositionedDirectional);

    await tester.pumpComponent(control(0));
    final start = tester.getCenter(indicator).dx;

    await tester.pumpComponent(control(2));
    await tester.pump(AppMotion.slow ~/ 2);
    final middle = tester.getCenter(indicator).dx;

    await tester.pumpAndSettle();
    final end = tester.getCenter(indicator).dx;

    expect(start, closeTo(tester.getCenter(find.text('A')).dx, 0.5));
    expect(middle, greaterThan(start));
    expect(middle, lessThan(end));
    expect(end, closeTo(tester.getCenter(find.text('C')).dx, 0.5));
  });

  testWidgets('sem animação quando o aparelho pede menos movimento', (
    tester,
  ) async {
    Widget control(int selected) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: SegmentedControl(
          options: const ['A', 'B', 'C'],
          selected: selected,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.pumpComponent(control(0));
    await tester.pumpComponent(control(2));
    await tester.pump();

    expect(
      tester.getCenter(find.byType(AnimatedPositionedDirectional)).dx,
      closeTo(tester.getCenter(find.text('C')).dx, 0.5),
    );
  });

  testWidgets('opção bloqueada não responde e fica riscada', (tester) async {
    int? changed;
    await tester.pumpComponent(
      SegmentedControl(
        options: const ['A', 'B'],
        selected: 0,
        disabled: const {1},
        onChanged: (i) => changed = i,
      ),
    );

    await tester.tap(find.text('B'));

    expect(changed, isNull);
    expect(
      tester.widget<Text>(find.text('B')).style?.decoration ??
          DefaultTextStyle.of(tester.element(find.text('B'))).style.decoration,
      TextDecoration.lineThrough,
    );
    expect(
      tester.getSemantics(find.text('B')),
      isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
    );
  });

  testWidgets('sem seleção esconde o indicador', (tester) async {
    await tester.pumpComponent(
      SegmentedControl(
        options: const ['A', 'B'],
        selected: null,
        onChanged: (_) {},
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first)
          .opacity,
      0,
    );
    expect(
      tester.getSemantics(find.text('A')),
      isSemantics(isButton: true, isSelected: false),
    );
  });
}
