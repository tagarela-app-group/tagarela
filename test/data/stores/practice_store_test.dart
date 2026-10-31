import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/exercise_service.dart';
import 'package:tagarela/data/services/review_service.dart';
import 'package:tagarela/data/storage/database.dart';
import 'package:tagarela/data/stores/practice_store.dart';

import '../../helpers/fake_practice_api.dart';

void main() {
  const attemptRoute = 'POST /api/v1/reviews/attempts';

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

  group('tentativa', () {
    late FakePracticeApi api;
    late AppDatabase db;
    late PracticeStore store;
    late Exercise exercise;
    final term = Term.fromJson(fenceTermJson);
    const owner = 'ana@example.com';

    setUp(() async {
      api = FakePracticeApi();
      db = AppDatabase(NativeDatabase.memory());
      store = PracticeStore(
        ReviewService(api),
        ExerciseService(api),
        db,
        owner: () => owner,
      );
      exercise = (await store.exercises(
        't-fence',
        ExerciseKind.listenWrite,
      )).first;
    });

    tearDown(() => db.close());

    test('com rede: sobe e sai da fila', () async {
      await store.record(term, exercise, Outcome.hint);

      expect(api.attempts.single, {
        'id': api.attempts.single['id'],
        'term': 't-fence',
        'kind': 'listen_write',
        'exercise': 'e-fence-0',
        'outcome': 'hint',
      });
      expect(await db.attemptsOf(owner), isEmpty);
    });

    test('sem rede: fica na fila e sobe ao carregar a sessão', () async {
      api.offline = true;

      await expectLater(
        store.record(term, exercise, Outcome.first),
        throwsA(isA<SocketException>()),
      );

      expect(await db.attemptsOf(owner), hasLength(1));

      api.offline = false;
      await store.load();

      expect(api.attempts.single['outcome'], 'first');
      expect(await db.attemptsOf(owner), isEmpty);
      expect(api.calls.last, startsWith('GET /api/v1/reviews'));
    });

    test('reenvio usa o mesmo id, pra API não subir dois níveis', () async {
      api.rejections[attemptRoute] = 503;
      await store
          .record(term, exercise, Outcome.first)
          .onError<Exception>((_, _) {});
      final id = api.bodies[attemptRoute]! as Json;
      api.rejections.remove(attemptRoute);

      await store.sendAttempts();

      expect(api.attempts.single['id'], id['id']);
    });

    test('429 e 5xx ficam na fila; recusa de verdade sai', () async {
      for (final (status, kept) in [(429, 1), (500, 1), (400, 0), (404, 0)]) {
        await db.delete(db.reviewAttemptRows).go();
        api.rejections[attemptRoute] = status;

        await store
            .record(term, exercise, Outcome.first)
            .onError<Exception>((_, _) {});

        expect(await db.attemptsOf(owner), hasLength(kept), reason: '$status');
      }
    });

    test('fila de outra conta não sobe', () async {
      await db.saveAttempt(
        'bia@example.com',
        const ReviewAttempt(
          id: 'a1',
          term: 't-fence',
          kind: ExerciseKind.listenWrite,
          exercise: null,
          outcome: Outcome.first,
        ),
      );

      await store.sendAttempts();

      expect(api.attempts, isEmpty);
    });
  });
}
