import 'package:tagarela/data/models/json.dart';

enum TermKind { word, expression }

enum TermStatus { learning, mastered }

class Term {
  const Term(this.id, this.text, this.translation, this.kind, this.level);

  Term.fromJson(Json json)
    : this(
        json['id']! as String,
        json['text']! as String,
        json['translation']! as String,
        TermKind.values.byName(json['kind']! as String),
        json['level']! as int,
      );

  final String id;
  final String text;
  final String translation;
  final TermKind kind;

  final int level;

  TermStatus get status =>
      level >= 4 ? TermStatus.mastered : TermStatus.learning;
}

extension TermList on List<Term> {
  int get masteredCount => where((t) => t.status == TermStatus.mastered).length;
}
