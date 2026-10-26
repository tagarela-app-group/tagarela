import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  String read(List<String> pieces, List<int> order) =>
      order.map((i) => pieces[i]).join(' ');

  test('cada passo troca um par vizinho até a ordem certa', () {
    const pieces = ['on', 'the', 'fence'];
    final steps = ShufflingTiles.steps(pieces);

    expect(steps.last, [0, 1, 2]);
    expect(steps, hasLength(4));
    for (var s = 0; s < steps.length - 1; s++) {
      final moved = [
        for (var k = 0; k < pieces.length; k++)
          if (steps[s][k] != steps[s + 1][k]) k,
      ];
      expect(moved, hasLength(2));
      expect(moved.last - moved.first, 1);
    }
  });

  test('peça repetida não gera embaralho igual ao certo', () {
    const pieces = ['step', 'by', 'step'];
    final steps = ShufflingTiles.steps(pieces);

    for (final order in steps.take(steps.length - 1)) {
      expect(read(pieces, order), isNot('step by step'));
    }
  });

  test('uma peça só fica parada', () {
    expect(ShufflingTiles.steps(['ok']), [
      [0],
    ]);
  });

  testWidgets('embaralha e chega na ordem certa', (tester) async {
    await tester.pumpComponent(
      const ShufflingTiles(pieces: ['on', 'the', 'fence']),
    );
    await tester.pump();

    double x(String piece) => tester.getTopLeft(find.text(piece)).dx;
    expect(x('fence') < x('on') || x('the') < x('on'), isTrue);

    for (var i = 0; i < 3; i++) {
      await tester.pump(AppMotion.shuffleStep);
    }
    await tester.pump(AppMotion.shuffle);

    expect(x('on'), lessThan(x('the')));
    expect(x('the'), lessThan(x('fence')));
  });

  testWidgets('termo longo quebra linha e cabe na largura', (tester) async {
    await tester.pumpComponent(
      const Center(
        child: SizedBox(
          width: 300,
          child: ShufflingTiles(
            pieces: [
              "don't",
              'count',
              'your',
              'chickens',
              'before',
              'they',
              'hatch',
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final box = tester.getSize(find.byType(ShufflingTiles));
    expect(box.width, 300);
    expect(box.height, greaterThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduzir movimento mostra montado e parado', (tester) async {
    await tester.pumpComponent(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: ShufflingTiles(pieces: ['on', 'the', 'fence']),
      ),
    );
    await tester.pump(AppMotion.shuffleHold);

    double x(String piece) => tester.getTopLeft(find.text(piece)).dx;
    expect(x('on'), lessThan(x('the')));
    expect(x('the'), lessThan(x('fence')));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
