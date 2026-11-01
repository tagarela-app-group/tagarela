import 'package:tagarela/data/models/exercise.dart';
import 'package:tagarela/data/models/json.dart';
import 'package:tagarela/data/models/term.dart';

enum Outcome { first, retry, hint, missed }

enum StudyEvent { read, listened }

enum RoundRating { poor, fair, good, great }

enum EffectRole {
  firstReview('first_review'),
  session('session'),
  retest('retest'),
  extra('extra');

  const EffectRole(this.key);

  final String key;

  static EffectRole fromKey(String key) =>
      values.where((role) => role.key == key).firstOrNull ?? extra;
}

String dayKey(DateTime day) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${day.year.toString().padLeft(4, '0')}-'
      '${two(day.month)}-${two(day.day)}';
}

class RoundPlay {
  const RoundPlay(
    this.outcome, {
    this.usedSlow = false,
    this.errors = 0,
    this.hints = 0,
    this.audioReplays = 0,
    this.responseMs,
  });

  final Outcome outcome;
  final bool usedSlow;
  final int errors;
  final int hints;
  final int audioReplays;
  final int? responseMs;
}

class ReviewAttempt {
  const ReviewAttempt({
    required this.id,
    required this.term,
    required this.kind,
    required this.exercise,
    required this.play,
    this.playedAt,
    this.localDate,
  });

  final String id;
  final String term;
  final ExerciseKind kind;
  final String? exercise;
  final RoundPlay play;
  final DateTime? playedAt;
  final String? localDate;
}

class ReviewEffect {
  const ReviewEffect({
    required this.role,
    required this.rating,
    required this.levelBefore,
    required this.level,
    required this.intervalBefore,
    required this.intervalDays,
    required this.dueAt,
  });

  factory ReviewEffect.fromJson(Json json) => ReviewEffect(
    role: EffectRole.fromKey(json['role']! as String),
    rating: RoundRating.values.byName(json['rating']! as String),
    levelBefore: json['level_before']! as int,
    level: json['level']! as int,
    intervalBefore: (json['interval_before']! as num).toDouble(),
    intervalDays: (json['interval_days']! as num).toDouble(),
    dueAt: switch (json['due_at']) {
      final String at => DateTime.parse(at),
      _ => null,
    },
  );

  final EffectRole role;
  final RoundRating rating;
  final int levelBefore;
  final int level;
  final double intervalBefore;
  final double intervalDays;
  final DateTime? dueAt;

  bool get isSession =>
      role == EffectRole.firstReview || role == EffectRole.session;

  bool get wentBadly => isSession && rating == RoundRating.poor;

  bool get mastered =>
      isSession && levelBefore < Term.maxLevel && level >= Term.maxLevel;

  bool get escaped =>
      isSession && levelBefore >= Term.maxLevel && level < Term.maxLevel;

  bool get stronger => isSession && intervalDays > intervalBefore;
}

class ReviewRound {
  const ReviewRound(this.term, this.kind, {this.retest = false});

  final Term term;
  final ExerciseKind kind;
  final bool retest;
}

class ReviewSession {
  const ReviewSession({
    required this.due,
    required this.rounds,
    this.done = 0,
    this.waiting = 0,
    this.unread = 0,
    this.nextDueAt,
  });

  factory ReviewSession.fromJson(Json json) => ReviewSession(
    due: json['due']! as int,
    done: json['done']! as int,
    waiting: json['waiting']! as int,
    unread: json['unread']! as int,
    nextDueAt: switch (json['next_due_at']) {
      final String at => DateTime.parse(at),
      _ => null,
    },
    rounds: [
      for (final round in (json['rounds']! as List).cast<Json>())
        if (ExerciseKind.fromKey(round['kind']! as String) case final kind?)
          ReviewRound(
            Term.fromJson(round['term']! as Json),
            kind,
            retest: round['retest']! as bool,
          ),
    ],
  );

  final int due;
  final int done;
  final int waiting;
  final int unread;
  final DateTime? nextDueAt;
  final List<ReviewRound> rounds;

  bool get hasSomething =>
      due > 0 || waiting > 0 || done > 0 || nextDueAt != null;
}
