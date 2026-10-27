import 'dart:math' as math;

import 'package:tagarela/data/models/models.dart';

sealed class SentenceToken {
  const SentenceToken(this.start, this.end);

  final int start;
  final int end;

  bool covers(int offset) => offset >= start && offset < end;
}

final class WordToken extends SentenceToken {
  const WordToken(this.text, super.start, super.end);

  final String text;
}

final class GapToken extends SentenceToken {
  const GapToken(this.chunks, super.start, super.end);

  final List<List<int>> chunks;
}

sealed class LinePiece {
  const LinePiece(this.space);

  final double space;
}

final class WordPiece extends LinePiece {
  const WordPiece(this.token, super.space);

  final WordToken token;
}

final class TilesPiece extends LinePiece {
  const TilesPiece(
    this.token,
    this.indices,
    super.space, {
    required this.first,
  });

  final GapToken token;
  final List<int> indices;
  final bool first;
}

final class HyphenPiece extends LinePiece {
  const HyphenPiece() : super(SentenceMetrics.glue);
}

class SentenceMetrics {
  const SentenceMetrics({
    required this.maxWidth,
    required this.space,
    required this.measure,
    required this.tileWidth,
    required this.tileGap,
    required this.groupPadding,
    required this.tileSpace,
    required this.hyphenWidth,
  });

  static const glue = 1.0;

  final double maxWidth;
  final double space;
  final double Function(String text) measure;
  final double Function(int index) tileWidth;
  final double tileGap;
  final double groupPadding;
  final double tileSpace;
  final double hyphenWidth;

  double groupWidth(List<int> indices) =>
      groupPadding * 2 +
      indices.fold(0.0, (sum, i) => sum + tileWidth(i)) +
      tileGap * math.max(0, indices.length - 1);
}

Set<int> syllableBreaks(String answer, String syllables) {
  if (syllables.replaceAll('|', '') != answer) return const {};
  final breaks = <int>{};
  var index = 0;
  for (final char in syllables.split('')) {
    if (char == '|') {
      breaks.add(index);
    } else {
      index++;
    }
  }
  return breaks;
}

List<SentenceToken> sentenceTokens(ListenWriteExercise exercise) {
  final sentence = exercise.sentence;
  final tokens = <SentenceToken>[];
  void words(int from, int to) {
    for (final m in RegExp(r'\S+').allMatches(sentence.substring(from, to))) {
      tokens.add(WordToken(m.group(0)!, from + m.start, from + m.end));
    }
  }

  words(0, exercise.start);
  final answer = exercise.answer;
  final breaks = syllableBreaks(answer, exercise.syllables);
  var index = 0;
  for (final word in answer.split(' ')) {
    if (word.isNotEmpty) {
      final chunks = <List<int>>[[]];
      for (var k = 0; k < word.length; k++) {
        if (k > 0 && breaks.contains(index + k)) chunks.add([]);
        chunks.last.add(index + k);
      }
      final start = exercise.start + index;
      tokens.add(GapToken(chunks, start, start + word.length));
    }
    index += word.length + 1;
  }
  words(exercise.end, sentence.length);
  return tokens;
}

List<List<LinePiece>> layoutSentence(
  List<SentenceToken> tokens,
  SentenceMetrics m,
) {
  final lines = <List<LinePiece>>[[]];
  var x = 0.0;

  List<LinePiece> line() => lines.last;

  void wrap() {
    lines.add([]);
    x = 0;
  }

  double spaceBefore({required bool glued, required bool tiles}) {
    if (line().isEmpty) return 0;
    if (glued) return SentenceMetrics.glue;
    return tiles || line().last is TilesPiece ? m.tileSpace : m.space;
  }

  SentenceToken? previous;
  for (final token in tokens) {
    final glued = previous != null && previous.end == token.start;
    previous = token;
    switch (token) {
      case WordToken():
        final width = m.measure(token.text);
        final space = spaceBefore(glued: false, tiles: false);
        if (line().isNotEmpty && !glued && x + space + width > m.maxWidth) {
          wrap();
        }
        final placed = spaceBefore(glued: glued, tiles: false);
        line().add(WordPiece(token, placed));
        x += placed + width;
      case GapToken():
        var rest = token.chunks;
        var first = true;
        while (rest.isNotEmpty) {
          final join = glued && first;
          final space = spaceBefore(glued: join, tiles: true);
          final whole = rest.expand((c) => c).toList();
          final width = m.groupWidth(whole);
          if (x + space + width <= m.maxWidth) {
            line().add(TilesPiece(token, whole, space, first: first));
            x += space + width;
            break;
          }
          if (width <= m.maxWidth && line().isNotEmpty) {
            wrap();
            continue;
          }
          var fit = 0;
          for (var k = 1; k < rest.length; k++) {
            final head = rest.take(k).expand((c) => c).toList();
            if (x + space + m.groupWidth(head) + m.hyphenWidth <= m.maxWidth) {
              fit = k;
            }
          }
          if (fit == 0 && line().isNotEmpty) {
            wrap();
            continue;
          }
          if (rest.length == 1) {
            line().add(TilesPiece(token, whole, space, first: first));
            x += space + width;
            break;
          }
          fit = math.max(1, fit);
          final head = rest.take(fit).expand((c) => c).toList();
          line()
            ..add(TilesPiece(token, head, space, first: first))
            ..add(const HyphenPiece());
          wrap();
          rest = rest.sublist(fit);
          first = false;
        }
    }
  }
  return [
    for (final l in lines)
      if (l.isNotEmpty) l,
  ];
}
