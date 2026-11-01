import 'package:tagarela/data/models/json.dart';

enum TermKind { word, expression }

enum TermStatus { learning, mastered }

class Term {
  const Term(this.id, this.text, this.kind, this.level, {this.createdAt});

  Term.fromJson(Json json)
    : this(
        json['id']! as String,
        json['text']! as String,
        TermKind.values.byName(json['kind']! as String),
        json['level']! as int,
        createdAt: switch (json['created_at']) {
          final String at => DateTime.parse(at),
          _ => null,
        },
      );

  final String id;
  final String text;
  final TermKind kind;

  static const maxLevel = 5;

  final int level;
  final DateTime? createdAt;

  TermStatus get status =>
      level >= maxLevel ? TermStatus.mastered : TermStatus.learning;
}

extension TermList on List<Term> {
  int get masteredCount => where((t) => t.status == TermStatus.mastered).length;
}
