import 'dart:math';

import 'package:tagarela/data/models.dart';

typedef Span = ({int start, int end});

enum TermLimit { tooLong, tooMany }

class Word {
  const Word({required this.label, required this.start, required this.end});

  final String label;
  final int start;
  final int end;

  bool get selectable => end > start;
}

class TermSelection {
  TermSelection(this.text, Iterable<Span> spans)
    : words = wordsOf(text),
      spans = List.unmodifiable(spans.toList()..sort(_byPosition));

  factory TermSelection.of(Capture capture) => TermSelection(capture.text, [
    for (final term in capture.terms)
      (
        start: _codeUnits(capture.text, term.start),
        end: _codeUnits(capture.text, term.end),
      ),
  ]);

  static const maxTextLength = Capture.maxTextLength;
  static const maxTerms = 50;
  static const maxTermLength = 100;

  final String text;
  final List<Word> words;
  final List<Span> spans;

  static final _lead = RegExp(r'^[^\p{L}\p{N}\p{M}]*', unicode: true);
  static final _tail = RegExp(r'[^\p{L}\p{N}\p{M}]*$', unicode: true);

  static List<Word> wordsOf(String text) => [
    for (final match in RegExp(r'\S+').allMatches(text))
      _word(match.group(0)!, match.start),
  ];

  static Word _word(String token, int offset) {
    final lead = _lead.firstMatch(token)!.end;
    final trail = _tail.firstMatch(token)!.start;
    return Word(
      label: token,
      start: offset + lead,
      end: offset + max(lead, trail),
    );
  }

  static int _byPosition(Span a, Span b) =>
      a.start != b.start ? a.start - b.start : b.end - a.end;

  Span spanOf(int first, int last) =>
      (start: words[first].start, end: words[last].end);

  String termText(Span span) => text.substring(span.start, span.end);

  bool has(Span span) => spans.contains(span);

  TermLimit? limit(Span span) {
    if (has(span)) return null;
    if (span.end - span.start > maxTermLength) return TermLimit.tooLong;
    if (spans.length >= maxTerms) return TermLimit.tooMany;
    return null;
  }

  TermSelection toggle(Span span) => TermSelection(
    text,
    has(span) ? spans.where((s) => s != span) : [...spans, span],
  );

  TermSelection remove(Span span) =>
      TermSelection(text, spans.where((s) => s != span));

  TermSelection edit(String after) {
    if (after == text) return this;
    final shortest = min(text.length, after.length);
    var prefix = 0;
    while (prefix < shortest && text[prefix] == after[prefix]) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < shortest - prefix &&
        text[text.length - 1 - suffix] == after[after.length - 1 - suffix]) {
      suffix++;
    }
    final delta = after.length - text.length;
    final changedEnd = text.length - suffix;
    final words = wordsOf(after);
    final starts = {for (final w in words) w.start};
    final ends = {for (final w in words) w.end};
    return TermSelection(
      after,
      [
        for (final span in spans)
          if (span.end <= prefix)
            span
          else if (span.start >= changedEnd)
            (start: span.start + delta, end: span.end + delta),
      ].where((s) => starts.contains(s.start) && ends.contains(s.end)),
    );
  }

  List<CaptureTerm> toTerms() => [
    for (final span in spans)
      CaptureTerm(
        text: termText(span),
        start: _codePoints(text, span.start),
        end: _codePoints(text, span.end),
      ),
  ];

  static int _codePoints(String text, int codeUnits) =>
      text.substring(0, codeUnits).runes.length;

  static int _codeUnits(String text, int codePoints) {
    var units = 0;
    var count = 0;
    for (final rune in text.runes) {
      if (count == codePoints) break;
      units += rune > 0xFFFF ? 2 : 1;
      count++;
    }
    return units;
  }
}
