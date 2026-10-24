import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

import 'fake_vocabulary_api.dart';

import 'fixtures.dart';

class FailingHomeStore extends HomeStore {
  FailingHomeStore() : super(sampleHome);

  bool failing = true;

  @override
  Future<HomeData> fetch() async =>
      failing ? throw Exception('falhou') : super.fetch();
}

class FailingVocabularyStore extends VocabularyStore {
  FailingVocabularyStore() : super(VocabularyService(FakeVocabularyApi()));

  bool failing = true;

  @override
  Future<Vocabulary> fetch() async =>
      failing ? throw Exception('falhou') : super.fetch();
}
