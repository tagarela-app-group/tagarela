import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';

import '../../helpers/fake_practice_api.dart';

void main() {
  test('kind conhecido pela chave da API; desconhecido vira null', () {
    expect(ExerciseKind.fromKey('listen_write'), ExerciseKind.listenWrite);
    expect(ExerciseKind.fromKey('crossword'), isNull);
  });

  test('ouvir e escrever lê frase, lacuna, tradução e extra', () {
    final exercise =
        Exercise.fromJson(listenWriteJson('e1'))! as ListenWriteExercise;

    expect(exercise.id, 'e1');
    expect(exercise.kind, ExerciseKind.listenWrite);
    expect(exercise.answer, 'on the fence');
    expect(exercise.syllables, 'on the fence');
    expect(
      exercise.translation,
      'Ainda tô em cima do muro sobre me mudar pra Lisboa.',
    );
    expect(exercise.extra.say, 'on the fence about');
  });

  test('responde aí lê a conversa e a lacuna da resposta', () {
    final exercise =
        Exercise.fromJson(replyJson('e1', mode: 'understand'))!
            as ReplyExercise;

    expect(exercise.kind, ExerciseKind.reply);
    expect(exercise.mode, ReplyMode.understand);
    expect(exercise.before, 'Not yet. ');
    expect(exercise.filled, "I'm still on the fence");
    expect(exercise.after, ' about it.');
  });

  test('mudança de assunto só entra com a conversa andando', () {
    final exercise = Exercise.fromJson(replyJson('e1'))! as ReplyExercise;

    expect(exercise.opening(continuing: false), 'Did you decide about Lisbon?');
    expect(
      exercise.opening(continuing: true),
      'Anyway! Did you decide about Lisbon?',
    );
  });

  test('posições da API contam caracteres, não unidades UTF-16', () {
    final exercise =
        Exercise.fromJson({
              'id': 'e2',
              'kind': 'listen_write',
              'variant': 0,
              'payload': {
                'sentence': '😅 So awkward.',
                'start': 5,
                'end': 12,
                'syllables': 'awk|ward',
                'translation': 'Que constrangedor.',
                'extra': {'note': '', 'say': ''},
              },
            })!
            as ListenWriteExercise;

    expect(exercise.answer, 'awkward');
  });

  test('exercício de tipo desconhecido é ignorado', () {
    expect(
      Exercise.fromJson({
        'id': 'x',
        'kind': 'crossword',
        'variant': 0,
        'payload': <String, Object?>{},
      }),
      isNull,
    );
  });

  test('sessão de revisão pula rodada de tipo desconhecido', () {
    final session = ReviewSession.fromJson({
      'due': 3,
      'done': 0,
      'waiting': 0,
      'unread': 0,
      'next_due_at': null,
      'kinds': ['listen_write', 'crossword'],
      'rounds': [
        {'term': fenceTermJson, 'kind': 'listen_write', 'retest': true},
        {'term': awkwardTermJson, 'kind': 'crossword', 'retest': false},
      ],
    });

    expect(session.due, 3);
    expect(session.kinds, [ExerciseKind.listenWrite]);
    expect(session.rounds.single.term.text, 'on the fence');
    expect(session.rounds.single.kind, ExerciseKind.listenWrite);
    expect(session.rounds.single.retest, isTrue);
  });

  test('dominado só no último nível', () {
    Term at(int level) => Term('t', 'x', TermKind.word, level);

    expect(at(Term.maxLevel - 1).status, TermStatus.learning);
    expect(at(Term.maxLevel).status, TermStatus.mastered);
  });
}
