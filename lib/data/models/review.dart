import 'package:tagarela/data/models/exercise.dart';
import 'package:tagarela/data/models/json.dart';
import 'package:tagarela/data/models/term.dart';

enum Outcome { first, retry, hint, missed }

class ReviewAttempt {
  const ReviewAttempt({
    required this.id,
    required this.term,
    required this.kind,
    required this.exercise,
    required this.outcome,
  });

  final String id;
  final String term;
  final ExerciseKind kind;
  final String? exercise;
  final Outcome outcome;
}

class ReviewRound {
  const ReviewRound(this.term, this.kind);

  final Term term;
  final ExerciseKind kind;
}

class ReviewSession {
  const ReviewSession({required this.due, required this.rounds});

  factory ReviewSession.fromJson(Json json) => ReviewSession(
    due: json['due']! as int,
    rounds: [
      for (final round in (json['rounds']! as List).cast<Json>())
        if (ExerciseKind.fromKey(round['kind']! as String) case final kind?)
          ReviewRound(Term.fromJson(round['term']! as Json), kind),
    ],
  );

  final int due;
  final List<ReviewRound> rounds;
}
