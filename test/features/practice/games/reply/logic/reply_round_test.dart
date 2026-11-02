import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/practice/games/reply/logic/reply_round.dart';

void main() {
  ReplyRound round() => ReplyRound('on the fence');

  test('acertar de primeira', () {
    final r = round();

    expect(r.pick('on the fence'), isTrue);
    expect(r.finished, isTrue);
    expect(r.outcome, Outcome.first);
  });

  test('o resultado piora a cada erro', () {
    final r = round()..pick('awkward');
    expect(r.outcome, Outcome.slip);

    r.pick('wit');
    expect(r.outcome, Outcome.retry);

    r.pick('gap');
    expect(r.outcome, Outcome.missed);

    expect(r.pick('on the fence'), isTrue);
    expect(r.outcome, Outcome.missed);
  });

  test('mesma opção errada não conta duas vezes', () {
    final r = round()
      ..pick('awkward')
      ..pick('awkward');

    expect(r.wrongs, ['awkward']);
    expect(r.isUsed('awkward'), isTrue);
    expect(r.outcome, Outcome.slip);
  });

  test('só dá pra mostrar a resposta depois de errar', () {
    final r = round();
    expect(r.canReveal, isFalse);

    r.pick('awkward');
    expect(r.canReveal, isTrue);

    r.reveal();
    expect(r.status, ReplyStatus.revealed);
    expect(r.outcome, Outcome.missed);
    expect(r.canReveal, isFalse);
  });

  test('depois de terminar, nada muda', () {
    final r = round()..pick('on the fence');

    expect(r.pick('awkward'), isFalse);
    r.reveal();

    expect(r.wrongs, isEmpty);
    expect(r.status, ReplyStatus.solved);
  });

  test('opção errada no começo da frase ganha maiúscula', () {
    expect(fitOption('awkward', ''), 'Awkward');
    expect(fitOption('awkward', 'Not yet. '), 'Awkward');
    expect(fitOption('awkward', "I'm still "), 'awkward');
  });
}
