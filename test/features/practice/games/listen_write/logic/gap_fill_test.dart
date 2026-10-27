import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/practice/games/listen_write/logic/gap_fill.dart';

void main() {
  void typeAll(GapFill fill, String letters) {
    for (final letter in letters.split('')) {
      fill.type(letter);
    }
  }

  test('só letra é casa; espaço e apóstrofo já vêm', () {
    final fill = GapFill("I'm at");

    expect(fill.letters, 4);
    expect(fill.isSlot(1), isFalse);
    expect(fill.isSlot(3), isFalse);
    expect(fill.cursor, 0);
  });

  test('digita na próxima casa livre e confere sem ligar pra maiúscula', () {
    final fill = GapFill('Procrastination');

    typeAll(fill, 'procrastination');

    expect(fill.complete, isTrue);
    expect(fill.check(), isTrue);
    expect(fill.status, GapStatus.solved);
    expect(fill.letterAt(0), 'P');
    expect(fill.outcome, Outcome.first);
  });

  test('não confere com casa vazia', () {
    final fill = GapFill('fence')..type('f');

    expect(fill.check(), isFalse);
    expect(fill.status, GapStatus.typing);
    expect(fill.left, 4);
  });

  test('erro marca as letras trocadas e a próxima tecla limpa só elas', () {
    final fill = GapFill('fence');
    typeAll(fill, 'fanse');

    expect(fill.check(), isFalse);
    expect(fill.status, GapStatus.wrong);
    expect(fill.wrongCount, 2);
    expect(
      [for (var i = 0; i < 5; i++) fill.isWrong(i)],
      [false, true, false, true, false],
    );

    fill.type('e');

    expect(fill.wrongCount, 0);
    expect(fill.letterAt(1), 'e');
    expect(fill.letterAt(3), isNull);
    expect(fill.cursor, 3);

    fill.type('c');
    expect(fill.check(), isTrue);
    expect(fill.outcome, Outcome.retry);
  });

  test('apagar tira a última letra digitada, mas não a dica', () {
    final fill = GapFill('fence')..hint();
    typeAll(fill, 'en');

    fill
      ..erase()
      ..erase()
      ..erase();

    expect(fill.letterAt(0), 'f');
    expect(fill.isHint(0), isTrue);
    expect(fill.left, 4);
  });

  test('apagar depois do erro limpa as letras erradas', () {
    final fill = GapFill('fence');
    typeAll(fill, 'fanse');
    fill
      ..check()
      ..erase();

    expect(fill.left, 2);
    expect(fill.wrongCount, 0);
  });

  test('dica põe a próxima letra que falta ou que está errada', () {
    final fill = GapFill('fence');
    typeAll(fill, 'fa');

    fill.hint();

    expect(fill.letterAt(1), 'e');
    expect(fill.isHint(1), isTrue);

    typeAll(fill, 'nce');
    expect(fill.check(), isTrue);
    expect(fill.outcome, Outcome.hint);
  });

  test('mostrar a resposta termina como vista', () {
    final fill = GapFill('fence')..type('x');

    fill.reveal();

    expect(fill.finished, isTrue);
    expect(fill.letterAt(4), 'e');
    expect(fill.cursor, isNull);
    expect(fill.outcome, Outcome.missed);

    fill.type('a');
    expect(fill.letterAt(0), 'f');
  });

  test('aceita letra com acento', () {
    final fill = GapFill('añoró');
    typeAll(fill, 'añoró');

    expect(fill.check(), isTrue);
  });
}
