import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/term/logic/term_pieces.dart';

void main() {
  test('expressão vira uma peça por palavra, com a pontuação junto', () {
    final split = termPieces("I'm at my wit's end");

    expect(split.pieces, ["I'm", 'at', 'my', "wit's", 'end']);
    expect(split.joined, isFalse);
  });

  test('palavra curta vira letras que se juntam', () {
    final split = termPieces('awkward');

    expect(split.pieces, ['a', 'w', 'k', 'w', 'a', 'r', 'd']);
    expect(split.joined, isTrue);
  });

  test('palavra com hífen parte no hífen', () {
    expect(termPieces('mother-in-law').pieces, ['mother-', 'in-', 'law']);
  });

  test('palavra longa vira pedaços perto das sílabas', () {
    expect(termPieces('procrastination').pieces, [
      'pro',
      'cras',
      'tina',
      'tion',
    ]);
    expect(termPieces('beautiful').pieces, ['beau', 'ti', 'ful']);
    expect(
      termPieces('desafortunadamente').pieces.join(),
      'desafortunadamente',
    );
    expect(termPieces('responsabilidade').pieces, hasLength(5));
  });

  test('espaço sobrando não vira peça', () {
    expect(termPieces('  sleep   on it ').pieces, ['sleep', 'on', 'it']);
  });
}
