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

    expect(
      practice.api.calls.single,
      startsWith('GET /api/v1/reviews?kinds=listen_write&date='),
    );
    expect(practice.store.data!.due, 2);
    expect(practice.store.data!.rounds, hasLength(2));
  });

  test('manda o dia e o fuso do aparelho ao pedir a sessão', () async {
    final api = FakePracticeApi();
    final now = DateTime(2026, 3, 7, 23, 30);
    final store = PracticeStore(
      ReviewService(api),
      ExerciseService(api),
      AppDatabase(NativeDatabase.memory()),
      owner: () => 'ana@example.com',
      now: () => now,
    );

    await store.load();

    expect(
      api.calls.single,
      'GET /api/v1/reviews?kinds=listen_write&date=2026-03-07'
      '&offset=${now.timeZoneOffset.inMinutes}',
    );
  });

  test('pedir mais revisões recarrega a sessão', () async {
    final practice = fakePractice();

    await practice.store.askForMore();

    expect(practice.api.askedForMore, 1);
    expect(practice.api.calls.last, startsWith('GET /api/v1/reviews'));
  });

  test('sem rede, pedir mais não quebra nem recarrega', () async {
    final practice = fakePractice()..api.offline = true;

    await practice.store.askForMore();

    expect(practice.api.askedForMore, 0);
    expect(practice.api.calls.where((c) => c.startsWith('GET')), isEmpty);
  });

  test('ler a ficha avisa a API e recarrega; ouvir só avisa', () async {
    final practice = fakePractice();

    await practice.store.study('t-fence', StudyEvent.listened);
    expect(practice.api.studied, [('t-fence', 'listened')]);
    expect(practice.api.calls.where((c) => c.startsWith('GET')), isEmpty);

    await practice.store.study('t-fence', StudyEvent.read);
    expect(practice.api.studied.last, ('t-fence', 'read'));
    expect(practice.api.calls.last, startsWith('GET /api/v1/reviews'));
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
    final playedAt = DateTime(2026, 11, 1, 22, 15);

    setUp(() async {
      api = FakePracticeApi();
      db = AppDatabase(NativeDatabase.memory());
      store = PracticeStore(
        ReviewService(api),
        ExerciseService(api),
        db,
        owner: () => owner,
        now: () => playedAt,
      );
      exercise = (await store.exercises(
        't-fence',
        ExerciseKind.listenWrite,
      )).first;
    });

    tearDown(() => db.close());

    test('com rede: sobe com os sinais, sai da fila e traz o efeito', () async {
      final effect = await store.record(
        term,
        exercise,
        const RoundPlay(
          Outcome.hint,
          usedSlow: true,
          errors: 1,
          hints: 2,
          audioReplays: 3,
          responseMs: 8200,
        ),
      );

      expect(api.attempts.single, {
        'id': api.attempts.single['id'],
        'term': 't-fence',
        'kind': 'listen_write',
        'exercise': 'e-fence-0',
        'outcome': 'hint',
        'used_slow': true,
        'errors': 1,
        'hints': 2,
        'audio_replays': 3,
        'response_ms': 8200,
        'played_at': playedAt.toUtc().toIso8601String(),
        'local_date': '2026-11-01',
      });
      expect(await db.attemptsOf(owner), isEmpty);
      expect(effect!.rating, RoundRating.great);
      expect(effect.intervalDays, 20);
    });

    test(
      'sinais na fila sobrevivem até subir, na ordem em que aconteceram',
      () async {
        await db.saveAttempt(
          owner,
          ReviewAttempt(
            id: 'depois',
            term: 't-fence',
            kind: ExerciseKind.listenWrite,
            exercise: null,
            play: const RoundPlay(Outcome.first, usedSlow: true, errors: 2),
            playedAt: playedAt.add(const Duration(hours: 1)),
            localDate: '2026-11-01',
          ),
        );
        await db.saveAttempt(
          owner,
          ReviewAttempt(
            id: 'antes',
            term: 't-fence',
            kind: ExerciseKind.listenWrite,
            exercise: null,
            play: const RoundPlay(Outcome.missed),
            playedAt: playedAt,
            localDate: '2026-11-01',
          ),
        );

        await store.sendAttempts();

        expect([for (final a in api.attempts) a['id']], ['antes', 'depois']);
        expect(api.attempts.last['used_slow'], isTrue);
        expect(api.attempts.last['errors'], 2);
      },
    );

    test('tentativa antiga, sem hora, sobe sem hora', () async {
      await db.saveAttempt(
        owner,
        const ReviewAttempt(
          id: 'a1',
          term: 't-fence',
          kind: ExerciseKind.listenWrite,
          exercise: null,
          play: RoundPlay(Outcome.first),
        ),
      );

      await store.sendAttempts();

      expect(api.attempts.single.containsKey('played_at'), isFalse);
      expect(api.attempts.single.containsKey('local_date'), isFalse);
    });

    test('sem rede: fica na fila e sobe ao carregar a sessão', () async {
      api.offline = true;

      await expectLater(
        store.record(term, exercise, const RoundPlay(Outcome.first)),
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
          .record(term, exercise, const RoundPlay(Outcome.first))
          .onError<Exception>((_, _) => null);
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
            .record(term, exercise, const RoundPlay(Outcome.first))
            .onError<Exception>((_, _) => null);

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
          play: RoundPlay(Outcome.first),
        ),
      );

      await store.sendAttempts();

      expect(api.attempts, isEmpty);
    });
  });
}
