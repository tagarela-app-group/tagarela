import 'package:tagarela/data/models/exercise.dart';
import 'package:tagarela/data/models/json.dart';
import 'package:tagarela/data/models/term.dart';

enum Outcome { first, retry, hint, missed }

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

  static const empty = ReviewSession(due: 0, rounds: []);

  final int due;
  final List<ReviewRound> rounds;
}
