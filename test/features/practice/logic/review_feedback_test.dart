import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/practice/logic/practice_session.dart';
import 'package:tagarela/features/practice/logic/review_feedback.dart';

import '../../../helpers/fake_practice_api.dart';
import '../../../helpers/l10n.dart';

final _now = DateTime(2026, 11, 1, 12);
final _term = Term.fromJson(fenceTermJson);
final _exercise = Exercise.fromJson(listenWriteJson('e'))!;

ReviewEffect _effect({
  EffectRole role = EffectRole.session,
  RoundRating rating = RoundRating.great,
  int levelBefore = 2,
  int level = 3,
  double intervalBefore = 8,
  double intervalDays = 20,
  Duration? back = const Duration(days: 20),
}) => ReviewEffect(
  role: role,
  rating: rating,
  levelBefore: levelBefore,
  level: level,
  intervalBefore: intervalBefore,
  intervalDays: intervalDays,
  dueAt: back == null ? null : _now.add(back),
);

PracticeResult _result(
  ReviewEffect? effect, {
  Outcome outcome = Outcome.first,
  bool usedSlow = false,
}) => (
  term: _term,
  exercise: _exercise,
  outcome: outcome,
  usedSlow: usedSlow,
  effect: effect,
);

void main() {
  group('roundFeedback', () {
    String? feedback(PracticeResult result) => roundFeedback(pt, result, _now);

    test('sem efeito ou tentativa sem efeito: nada a dizer', () {
      expect(feedback(_result(null)), isNull);
      expect(feedback(_result(_effect(role: EffectRole.extra))), isNull);
    });

    test('de primeira e sem Devagar comemora e diz quando volta', () {
      expect(
        feedback(_result(_effect())),
        'De primeira e sem Devagar! Volta em 20 dias.',
      );
    });

    test('de primeira com Devagar não comemora igual', () {
      expect(
        feedback(_result(_effect(), usedSlow: true)),
        'De primeira, com uma força do Devagar. Volta em 20 dias.',
      );
    });

    test('foi bem com ajuda só diz quando volta', () {
      expect(
        feedback(_result(_effect(), outcome: Outcome.hint)),
        'Volta em 20 dias.',
      );
    });

    test('foi mal volta em horas, sem bronca', () {
      expect(
        feedback(
          _result(
            _effect(
              rating: RoundRating.poor,
              back: const Duration(hours: 4),
              intervalDays: 2,
            ),
            outcome: Outcome.missed,
          ),
        ),
        'Sem drama, esse volta logo. Volta em 4 horas.',
      );
    });

    test('virou dominado e escapou têm texto próprio', () {
      expect(
        feedback(_result(_effect(levelBefore: 4, level: 5))),
        'Dominou! Volta em 20 dias.',
      );
      expect(
        feedback(
          _result(
            _effect(levelBefore: 5, level: 3, rating: RoundRating.fair),
            outcome: Outcome.retry,
          ),
        ),
        'Escapou um pouco, sem problema. Volta em 20 dias.',
      );
    });

    test('reteste avisa que volta amanhã', () {
      expect(
        feedback(_result(_effect(role: EffectRole.retest))),
        'Anotado! Ele volta amanhã.',
      );
    });
  });

  group('sessionRecap', () {
    test('conta o que mudou', () {
      expect(
        sessionRecap(pt, [
          _result(_effect()),
          _result(_effect()),
          _result(_effect(levelBefore: 4, level: 5)),
          _result(_effect(rating: RoundRating.poor, intervalDays: 2)),
        ]),
        '2 ficaram mais fortes, 1 foi dominado, 1 volta hoje',
      );
    });

    test('reteste e tentativa sem efeito não contam', () {
      expect(
        sessionRecap(pt, [
          _result(_effect(role: EffectRole.retest)),
          _result(_effect(role: EffectRole.extra)),
        ]),
        isNull,
      );
    });

    test('sem rede não há o que contar', () {
      expect(sessionRecap(pt, [_result(null)]), isNull);
    });
  });
}
