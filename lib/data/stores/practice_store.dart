import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/exercise_service.dart';
import 'package:tagarela/data/services/review_service.dart';
import 'package:tagarela/data/stores/store.dart';

class PracticeStore extends Store<ReviewSession> {
  PracticeStore(this._reviews, this._exercises);

  final ReviewService _reviews;
  final ExerciseService _exercises;

  @override
  Future<ReviewSession> fetch() => _reviews.session(ExerciseKind.values);

  Future<List<Exercise>> exercises(String termId, ExerciseKind kind) =>
      _exercises.forTerm(termId, kind);

  Future<Term> record(Term term, Exercise exercise, Outcome outcome) =>
      _reviews.record(
        termId: term.id,
        kind: exercise.kind,
        exerciseId: exercise.id,
        outcome: outcome,
      );
}
