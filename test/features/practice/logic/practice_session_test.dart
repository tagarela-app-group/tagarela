import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/practice/logic/practice_session.dart';

import '../../../helpers/fake_practice_api.dart';

final fence = Term.fromJson(fenceTermJson);
final awkward = Term.fromJson(awkwardTermJson);

class Loader {
  final calls = <String>[];
  final failing = <String>{};
  final lists = <String, List<Exercise>>{
    fence.id: [
      Exercise.fromJson(listenWriteJson('f0'))!,
      Exercise.fromJson(listenWriteJson('f1'))!,
    ],
    awkward.id: [
      Exercise.fromJson(
        listenWriteJson('a0', sentence: 'So awkward.', answer: 'awkward'),
      )!,
    ],
  };

  Future<List<Exercise>> call(Term term, ExerciseKind kind) async {
    calls.add(term.id);
    if (failing.contains(term.id)) throw Exception('falhou');
    return lists[term.id]!;
  }
}

void main() {
  late Loader loader;

  setUp(() => loader = Loader());

  test('abre a primeira rodada e já busca a próxima', () async {
    final session = PracticeSession([
      PracticeRound(fence, ExerciseKind.listenWrite),
      PracticeRound(awkward, ExerciseKind.listenWrite),
    ], load: loader.call);

    await session.start();
    await pumpEventQueue();

    expect(session.exercise!.id, 'f0');
    expect(session.index, 0);
    expect(loader.calls, [fence.id, awkward.id]);
  });

  test('resolver guarda o resultado; próxima avança até o fim', () async {
    final session = PracticeSession([
      PracticeRound(fence, ExerciseKind.listenWrite),
      PracticeRound(awkward, ExerciseKind.listenWrite),
    ], load: loader.call);
    await session.start();

    session.next();
    expect(session.index, 0);

    session.solve(const RoundPlay(Outcome.hint));
    session.solve(const RoundPlay(Outcome.first));
    expect(session.outcome, Outcome.hint);

    session.next();
    await pumpEventQueue();
    expect(session.exercise!.id, 'a0');

    session
      ..solve(const RoundPlay(Outcome.missed))
      ..next();
    await pumpEventQueue();

    expect(session.done, isTrue);
    expect(
      [for (final r in session.results) r.outcome],
      [Outcome.hint, Outcome.missed],
    );
    expect(
      [for (final r in session.results) r.term.id],
      [fence.id, awkward.id],
    );
  });

  test('variações do mesmo termo saem de uma busca só', () async {
    final session = PracticeSession([
      for (var v = 0; v < 3; v++)
        PracticeRound(fence, ExerciseKind.listenWrite, variant: v),
    ], load: loader.call);

    await session.start();

    expect(session.total, 2);

    session
      ..solve(const RoundPlay(Outcome.first))
      ..next();
    await pumpEventQueue();

    expect(session.exercise!.id, 'f1');
    expect(loader.calls, [fence.id]);
  });

  test('só grava a tentativa quando tem gravador', () async {
    final recorded = <(String, String, RoundPlay)>[];
    final session = PracticeSession(
      [PracticeRound(fence, ExerciseKind.listenWrite)],
      load: loader.call,
      record: (term, exercise, play) async {
        recorded.add((term.id, exercise.id, play));
        return null;
      },
    );
    await session.start();

    const play = RoundPlay(Outcome.retry, usedSlow: true);
    session.solve(play);
    await pumpEventQueue();

    expect(recorded, [(fence.id, 'f0', play)]);
  });

  test('o efeito que a API devolve entra no resultado da rodada', () async {
    final effect = ReviewEffect.fromJson(attemptEffectJson);
    final session = PracticeSession(
      [PracticeRound(fence, ExerciseKind.listenWrite)],
      load: loader.call,
      record: (_, _, _) async => effect,
    );
    await session.start();

    session.solve(const RoundPlay(Outcome.first, usedSlow: true));
    expect(session.current!.effect, isNull);
    expect(session.current!.usedSlow, isTrue);

    await pumpEventQueue();

    expect(session.current!.effect, effect);
    expect(session.results.single.effect, effect);
  });

  test('falha ao gravar não atrapalha a rodada', () async {
    final session = PracticeSession(
      [PracticeRound(fence, ExerciseKind.listenWrite)],
      load: loader.call,
      record: (_, _, _) => Future.error(Exception('sem rede')),
    );
    await session.start();

    session.solve(const RoundPlay(Outcome.first));
    await pumpEventQueue();

    expect(session.outcome, Outcome.first);
  });

  test('erro ao buscar: mostra o erro e tenta de novo', () async {
    loader.failing.add(fence.id);
    final session = PracticeSession([
      PracticeRound(fence, ExerciseKind.listenWrite),
    ], load: loader.call);

    await session.start();
    expect(session.error, isNotNull);
    expect(session.exercise, isNull);

    loader.failing.clear();
    await session.retry();

    expect(session.error, isNull);
    expect(session.exercise!.id, 'f0');
    expect(loader.calls, [fence.id, fence.id]);
  });

  test('descartada no meio da busca não avisa ninguém', () async {
    final gate = Completer<List<Exercise>>();
    final session = PracticeSession([
      PracticeRound(fence, ExerciseKind.listenWrite),
    ], load: (_, _) => gate.future);
    final started = session.start();

    session.dispose();
    gate.complete(loader.lists[fence.id]!);

    await expectLater(started, completes);
  });
}
