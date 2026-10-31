import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/data/services/exercise_service.dart';
import 'package:tagarela/data/services/review_service.dart';
import 'package:tagarela/data/storage/database.dart';
import 'package:tagarela/data/stores/store.dart';

class PracticeStore extends Store<ReviewSession> {
  PracticeStore(
    this._reviews,
    this._exercises,
    this._db, {
    required this._owner,
  });

  final ReviewService _reviews;
  final ExerciseService _exercises;
  final AppDatabase _db;
  final String? Function() _owner;

  Future<void> _sending = Future.value();

  @override
  Future<ReviewSession> fetch() async {
    await sendAttempts().onError<Exception>((_, _) {});
    return _reviews.session(ExerciseKind.values);
  }

  Future<List<Exercise>> exercises(String termId, ExerciseKind kind) =>
      _exercises.forTerm(termId, kind);

  Future<void> record(Term term, Exercise exercise, Outcome outcome) async {
    final owner = _owner();
    if (owner == null) return;
    await _db.saveAttempt(
      owner,
      ReviewAttempt(
        id: newUuid(),
        term: term.id,
        kind: exercise.kind,
        exercise: exercise.id,
        outcome: outcome,
      ),
    );
    await sendAttempts();
  }

  Future<void> sendAttempts() =>
      _sending = _sending.onError((_, _) {}).then((_) => _send());

  Future<void> _send() async {
    final owner = _owner();
    if (owner == null) return;
    for (final attempt in await _db.attemptsOf(owner)) {
      try {
        await _reviews.record(attempt);
      } on ApiException catch (e) {
        if (!e.rejected) rethrow;
      }
      await _db.deleteAttempt(attempt.id);
    }
  }
}
