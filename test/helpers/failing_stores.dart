import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

import 'fixtures.dart';

class FailingHomeStore extends HomeStore {
  FailingHomeStore() : super(sampleHome);

  bool failing = true;

  @override
  Future<HomeData> fetch() async =>
      failing ? throw Exception('falhou') : super.fetch();
}

class FailingVocabularyStore extends VocabularyStore {
  FailingVocabularyStore() : super(sampleGroups);

  bool failing = true;

  @override
  Future<List<TermGroup>> fetch() async =>
      failing ? throw Exception('falhou') : super.fetch();
}
