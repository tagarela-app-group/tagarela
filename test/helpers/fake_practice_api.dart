import 'dart:async';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/data/services/exercise_service.dart';
import 'package:tagarela/data/services/review_service.dart';
import 'package:tagarela/data/stores/practice_store.dart';

import 'fake_api.dart';

const Json fenceTermJson = {
  'id': 't-fence',
  'text': 'on the fence',
  'translation': 'em cima do muro',
  'kind': 'expression',
  'level': 2,
};

const Json awkwardTermJson = {
  'id': 't-awkward',
  'text': 'awkward',
  'translation': 'constrangedor',
  'kind': 'word',
  'level': 0,
};

Json listenWriteJson(
  String id, {
  String sentence = "I'm still on the fence about moving to Lisbon.",
  String answer = 'on the fence',
  String? syllables,
  String note = 'Depois vem *about*: *on the fence about* alguma coisa.',
  String say = 'on the fence about',
}) {
  final start = sentence.indexOf(answer);
  return {
    'id': id,
    'kind': 'listen_write',
    'variant': 0,
    'payload': {
      'sentence': sentence,
      'start': start,
      'end': start + answer.length,
      'syllables': syllables ?? answer,
      'translation': 'Ainda tô em cima do muro sobre me mudar pra Lisboa.',
      'extra': {'note': note, 'say': say},
    },
  };
}

class FakePracticeApi extends FakeApi {
  FakePracticeApi({this.due = 2, List<Json>? rounds})
    : rounds =
          rounds ??
          [
            {'term': fenceTermJson, 'kind': 'listen_write'},
            {'term': awkwardTermJson, 'kind': 'listen_write'},
          ];

  int due;
  final List<Json> rounds;
  final attempts = <Map<String, Object?>>[];
  final exercises = <String, List<Json>>{
    't-fence': [
      listenWriteJson('e-fence-0'),
      listenWriteJson(
        'e-fence-1',
        sentence: 'She stayed on the fence during the meeting.',
      ),
    ],
    't-awkward': [
      listenWriteJson(
        'e-awkward-0',
        sentence: 'That silence after his joke was so awkward.',
        answer: 'awkward',
        syllables: 'awk|ward',
        note: 'Vale pra gente também: *an awkward guy*.',
        say: 'an awkward guy',
      ),
    ],
  };
  final failing = <String>{};
  Completer<void>? hold;

  @override
  Future<Object?> respond(
    String method,
    String path,
    Map<String, Object?>? body,
  ) async {
    if (method == 'POST') return _attempt(body!);
    if (path.startsWith('/api/v1/reviews')) {
      return {'due': due, 'rounds': rounds};
    }
    await hold?.future;
    final termId = path.split('/')[4];
    if (failing.contains(termId)) throw ApiException(503, 'GET $path');
    return {'exercises': exercises[termId] ?? const <Json>[]};
  }

  Json _attempt(Map<String, Object?> body) {
    attempts.add(body);
    final term = [
      for (final r in rounds) r['term']! as Json,
    ].firstWhere((t) => t['id'] == body['term']);
    return {
      'term': {...term, 'level': (term['level']! as int) + 1},
    };
  }
}

typedef FakePractice = ({PracticeStore store, FakePracticeApi api});

FakePractice fakePractice([FakePracticeApi? api]) {
  final fake = api ?? FakePracticeApi();
  return (
    store: PracticeStore(ReviewService(fake), ExerciseService(fake)),
    api: fake,
  );
}

PracticeStore emptyPractice() =>
    fakePractice(FakePracticeApi(due: 0, rounds: [])).store;
