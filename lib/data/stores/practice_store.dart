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
    this._now = DateTime.now,
  });

  final ReviewService _reviews;
  final ExerciseService _exercises;
  final AppDatabase _db;
  final String? Function() _owner;
  final DateTime Function() _now;
  final _effects = <String, ReviewEffect>{};

  Future<void> _sending = Future.value();

  @override
  Future<ReviewSession> fetch() async {
    await sendAttempts().onError<Exception>((_, _) {});
    return _reviews.session(ExerciseKind.values, _now());
  }

  Future<List<Exercise>> exercises(String termId, ExerciseKind kind) =>
      _exercises.forTerm(termId, kind);

  Future<ReviewEffect?> record(
    Term term,
    Exercise exercise,
    RoundPlay play,
  ) async {
    final owner = _owner();
    if (owner == null) return null;
    final now = _now();
    final attempt = ReviewAttempt(
      id: newUuid(),
      term: term.id,
      kind: exercise.kind,
      exercise: exercise.id,
      play: play,
      playedAt: now,
      localDate: dayKey(now),
    );
    await _db.saveAttempt(owner, attempt);
    await sendAttempts();
    return _effects.remove(attempt.id);
  }

  Future<void> askForMore() async {
    try {
      await _reviews.askForMore();
    } on Exception {
      return;
    }
    await load();
  }

  Future<void> study(String termId, StudyEvent event) async {
    await _reviews.study(termId, event);
    if (event == StudyEvent.read) await load();
  }

  Future<void> sendAttempts() =>
      _sending = _sending.onError((_, _) {}).then((_) => _send());

  Future<void> _send() async {
    final owner = _owner();
    if (owner == null) return;
    for (final attempt in await _db.attemptsOf(owner)) {
      try {
        _effects[attempt.id] = await _reviews.record(attempt);
      } on ApiException catch (e) {
        if (!e.rejected) rethrow;
      }
      await _db.deleteAttempt(attempt.id);
    }
  }
}
