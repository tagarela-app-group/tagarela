import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';

import '../../helpers/fake_practice_api.dart';

void main() {
  test('carrega a sessão pedindo os tipos que o app joga', () async {
    final practice = fakePractice();

    await practice.store.load();

    expect(practice.api.calls, ['GET /api/v1/reviews?kinds=listen_write']);
    expect(practice.store.data!.due, 2);
    expect(practice.store.data!.rounds, hasLength(2));
  });

  test('busca os exercícios do termo por tipo', () async {
    final practice = fakePractice();

    final exercises = await practice.store.exercises(
      't-fence',
      ExerciseKind.listenWrite,
    );

    expect(practice.api.calls, [
      'GET /api/v1/terms/t-fence/exercises/listen_write',
    ]);
    expect([for (final e in exercises) e.id], ['e-fence-0', 'e-fence-1']);
  });

  test('grava a tentativa e devolve o termo com o nível novo', () async {
    final practice = fakePractice();
    final exercise = (await practice.store.exercises(
      't-fence',
      ExerciseKind.listenWrite,
    )).first;
    final term = Term.fromJson(fenceTermJson);

    final updated = await practice.store.record(term, exercise, Outcome.hint);

    expect(practice.api.attempts.single, {
      'term': 't-fence',
      'kind': 'listen_write',
      'exercise': 'e-fence-0',
      'outcome': 'hint',
    });
    expect(updated.level, 3);
  });
}
