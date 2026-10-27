import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:tagarela/data/models/models.dart';

class PracticeRound {
  const PracticeRound(this.term, this.kind, {this.variant = 0});

  final Term term;
  final ExerciseKind kind;
  final int variant;
}

typedef PracticeResult = ({Term term, Exercise exercise, Outcome outcome});

typedef ExerciseLoader =
    Future<List<Exercise>> Function(Term term, ExerciseKind kind);

typedef AttemptRecorder =
    Future<void> Function(Term term, Exercise exercise, Outcome outcome);

class PracticeSession extends ChangeNotifier {
  PracticeSession(List<PracticeRound> rounds, {required this.load, this.record})
    : _rounds = [...rounds];

  final ExerciseLoader load;
  final AttemptRecorder? record;
  final List<PracticeRound> _rounds;
  final _lists = <(String, ExerciseKind), Future<List<Exercise>>>{};
  final _results = <PracticeResult>[];
  var _index = 0;
  Exercise? _exercise;
  Object? _error;
  Outcome? _outcome;
  var _disposed = false;

  int get index => _index;
  int get total => _rounds.length;
  bool get done => _index >= _rounds.length;
  bool get records => record != null;
  PracticeRound? get round => done ? null : _rounds[_index];
  Exercise? get exercise => _exercise;
  Object? get error => _error;
  Outcome? get outcome => _outcome;
  List<PracticeResult> get results => List.unmodifiable(_results);

  Future<void> start() => _open();

  Future<void> retry() => _open();

  void solve(Outcome outcome) {
    final exercise = _exercise;
    final round = this.round;
    if (exercise == null || round == null || _outcome != null) return;
    _outcome = outcome;
    _results.add((term: round.term, exercise: exercise, outcome: outcome));
    _notify();
    final record = this.record;
    if (record != null) {
      unawaited(
        record(round.term, exercise, outcome).then((_) {}, onError: (_) {}),
      );
    }
  }

  void next() {
    if (_outcome == null) return;
    _index++;
    unawaited(_open());
  }

  Future<void> _open() async {
    _exercise = null;
    _error = null;
    _outcome = null;
    final round = this.round;
    _notify();
    if (round == null) return;
    try {
      final list = await _list(round);
      if (_disposed || !identical(round, this.round)) return;
      _rounds.removeWhere(
        (r) =>
            r.term.id == round.term.id &&
            r.kind == round.kind &&
            r.variant >= list.length,
      );
      if (round.variant >= list.length) return _open();
      _exercise = list[round.variant];
      _prefetch();
    } on Exception catch (e) {
      _lists.remove(_key(round));
      _error = e;
    }
    _notify();
  }

  void _prefetch() {
    if (_index + 1 >= _rounds.length) return;
    final next = _rounds[_index + 1];
    unawaited(
      _list(next).then((_) {}, onError: (_) => _lists.remove(_key(next))),
    );
  }

  Future<List<Exercise>> _list(PracticeRound round) =>
      _lists.putIfAbsent(_key(round), () => load(round.term, round.kind));

  (String, ExerciseKind) _key(PracticeRound round) =>
      (round.term.id, round.kind);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
