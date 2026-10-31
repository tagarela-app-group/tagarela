import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

import 'fake_vocabulary_api.dart';

class FailingVocabularyStore extends VocabularyStore {
  FailingVocabularyStore() : super(VocabularyService(FakeVocabularyApi()));

  bool failing = true;

  @override
  Future<Vocabulary> fetch() async =>
      failing ? throw Exception('falhou') : super.fetch();
}
