import 'package:tagarela/data/models/json.dart';
import 'package:tagarela/data/models/term.dart';

class DailyWord {
  const DailyWord({
    required this.text,
    required this.kind,
    required this.phonetic,
    required this.example,
    required this.meaning,
    required this.term,
  });

  factory DailyWord.fromJson(Json json) => DailyWord(
    text: json['text']! as String,
    kind: TermKind.values.byName(json['kind']! as String),
    phonetic: json['phonetic'] as String?,
    example: json['example']! as String,
    meaning: json['meaning']! as String,
    term: switch (json['term']) {
      final Json term => Term.fromJson(term),
      _ => null,
    },
  );

  final String text;
  final TermKind kind;
  final String? phonetic;
  final String example;
  final String meaning;
  final Term? term;
}
