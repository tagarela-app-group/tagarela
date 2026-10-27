import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/practice/games/listen_write/logic/sentence_layout.dart';

ListenWriteExercise exercise(
  String sentence,
  String answer, {
  String? syllables,
}) {
  final start = sentence.indexOf(answer);
  return ListenWriteExercise(
    id: 'e',
    sentence: sentence,
    start: start,
    end: start + answer.length,
    syllables: syllables ?? answer,
    translation: '',
    extra: const ExerciseExtra(note: '', say: ''),
  );
}

SentenceMetrics metrics(double maxWidth) => SentenceMetrics(
  maxWidth: maxWidth,
  space: 5,
  measure: (text) => text.length * 10,
  tileWidth: (_) => 20,
  tileGap: 2,
  groupPadding: 3,
  tileSpace: 7,
  hyphenWidth: 6,
);

String describe(List<List<LinePiece>> lines) => [
  for (final line in lines)
    [
      for (final piece in line)
        switch (piece) {
          WordPiece(:final token) => token.text,
          TilesPiece(:final indices) => '[${indices.join(',')}]',
          HyphenPiece() => '-',
        },
    ].join(' '),
].join(' / ');

void main() {
  test('frase vira palavras e a lacuna vira uma peça por palavra', () {
    final tokens = sentenceTokens(
      exercise("I'm still on the fence about it.", 'on the fence'),
    );

    expect(tokens.map((t) => t.runtimeType).toList(), [
      WordToken,
      WordToken,
      GapToken,
      GapToken,
      GapToken,
      WordToken,
      WordToken,
    ]);
    final fence = tokens[4] as GapToken;
    expect(fence.chunks, [
      [7, 8, 9, 10, 11],
    ]);
    expect((fence.start, fence.end), (17, 22));
  });

  test('sílabas viram pedaços da palavra', () {
    final tokens = sentenceTokens(
      exercise(
        'Procrastination wins.',
        'Procrastination',
        syllables: 'Pro|cras|ti|na|tion',
      ),
    );

    expect((tokens.first as GapToken).chunks.map((c) => c.length), [
      3,
      4,
      2,
      2,
      4,
    ]);
  });

  test('sílabas que não batem com a resposta são ignoradas', () {
    expect(syllableBreaks('awkward', 'awk|wird'), isEmpty);
    expect(syllableBreaks('awkward', 'awk|ward'), {3});
  });

  test('cabe na linha: fica tudo junto', () {
    final lines = layoutSentence(
      sentenceTokens(exercise('So awkward now.', 'awkward')),
      metrics(400),
    );

    expect(describe(lines), 'So [0,1,2,3,4,5,6] now.');
  });

  test('pontuação colada na lacuna não ganha espaço', () {
    final lines = layoutSentence(
      sentenceTokens(exercise('It was awkward.', 'awkward')),
      metrics(400),
    );

    expect((lines.single.last as WordPiece).space, SentenceMetrics.glue);
  });

  test('palavra que cabe na linha de baixo desce inteira, sem hífen', () {
    final lines = layoutSentence(
      sentenceTokens(
        exercise('Stop it now awkward', 'awkward', syllables: 'awk|ward'),
      ),
      metrics(200),
    );

    expect(describe(lines), 'Stop it now / [0,1,2,3,4,5,6]');
  });

  test('palavra maior que a linha quebra na sílaba, com hífen no fim', () {
    final lines = layoutSentence(
      sentenceTokens(
        exercise(
          'Procrastination wins.',
          'Procrastination',
          syllables: 'Pro|cras|ti|na|tion',
        ),
      ),
      metrics(250),
    );

    expect(describe(lines), '[0,1,2,3,4,5,6,7,8] - / [9,10,11,12,13,14] wins.');
    final second = lines[1].first as TilesPiece;
    expect(second.first, isFalse);
    expect(second.space, 0);
  });

  test('palavra sem sílaba maior que a linha fica numa linha só', () {
    final lines = layoutSentence(
      sentenceTokens(exercise('Supercalifragilistic', 'Supercalifragilistic')),
      metrics(100),
    );

    expect(lines, hasLength(1));
    expect(lines.single.whereType<HyphenPiece>(), isEmpty);
  });
}
