import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/data/services/daily_word_service.dart';
import 'package:tagarela/data/stores/daily_word_store.dart';

import 'fake_api.dart';

const Json hangryJson = {
  'text': 'hangry',
  'kind': 'word',
  'phonetic': '/ˈhæŋ.ɡri/',
  'example': "Feed me, I'm getting hangry!",
  'meaning': 'com fome e de mau humor',
  'term': null,
};

const Json hangryTermJson = {
  'id': 't-hangry',
  'text': 'hangry',
  'translation': '',
  'kind': 'word',
  'level': 0,
};

class FakeDailyWordApi extends FakeApi {
  FakeDailyWordApi({this.word});

  Json? word;

  @override
  Object? respond(String method, String path, Map<String, Object?>? body) {
    final current = word;
    if (current == null) throw ApiException(404, '$method $path');
    if (method == 'POST') word = {...current, 'term': hangryTermJson};
    return word;
  }
}

typedef FakeDailyWord = ({
  DailyWordStore store,
  FakeDailyWordApi api,
  List<String> saved,
});

FakeDailyWord fakeDailyWord([FakeDailyWordApi? api]) {
  final fake = api ?? FakeDailyWordApi();
  final saved = <String>[];
  return (
    store: DailyWordStore(
      DailyWordService(fake),
      onSaved: () async => saved.add('recarregou'),
    ),
    api: fake,
    saved: saved,
  );
}
