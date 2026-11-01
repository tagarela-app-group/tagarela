import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/home/logic/word_acts.dart';

void main() {
  test('os números se revezam e voltam ao primeiro', () {
    expect(
      [for (var round = 0; round < 4; round++) actOfRound(round)],
      [WordAct.hop, WordAct.shuffle, WordAct.chat, WordAct.hop],
    );
  });

  test('todo número começa e termina com a palavra no lugar', () {
    for (final act in WordAct.values) {
      for (final count in [1, 2, 6, 15]) {
        for (var i = 0; i < count; i++) {
          for (final t in [0.0, 1.0]) {
            final pose = letterPose(act, t, i, count);
            final reason = '$act t=$t letra $i de $count';
            expect(pose.slots, closeTo(0, 1e-9), reason: reason);
            expect(pose.lift, closeTo(0, 1e-9), reason: reason);
            expect(pose.angle, closeTo(0, 1e-9), reason: reason);
            expect(pose.squash, closeTo(0, 1e-9), reason: reason);
            expect(pose.tinted, isFalse, reason: reason);
          }
        }
      }
    }
  });

  test('pulo: as letras sobem uma depois da outra', () {
    final first = letterPose(WordAct.hop, 0.1, 0, 6);
    final last = letterPose(WordAct.hop, 0.1, 5, 6);

    expect(first.lift, greaterThan(0));
    expect(last.lift, closeTo(0, 1e-9));
  });

  test('embaralha: as letras trocam de lugar, sem cair na mesma vaga', () {
    const count = 6;
    for (final t in [0.25, 0.5, 0.75]) {
      final spots = {
        for (var i = 0; i < count; i++)
          (i + letterPose(WordAct.shuffle, t, i, count).slots).round(),
      };
      expect(spots, hasLength(count), reason: 't=$t');
    }
    expect(letterPose(WordAct.shuffle, 0.5, 0, count).slots, isNot(0));
    expect(letterPose(WordAct.shuffle, 0.5, 0, count).tinted, isTrue);
  });

  test('tagarela: as letras balançam sem sair do lugar', () {
    final pose = letterPose(WordAct.chat, 0.1, 0, 6);

    expect(pose.angle, isNot(0));
    expect(pose.slots, 0);
    expect(pose.lift, 0);
  });
}
