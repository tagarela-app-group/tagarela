import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/store.dart';

class VocabularyStore extends Store<List<TermGroup>> {
  VocabularyStore(this._service);

  final VocabularyService _service;

  @override
  Future<List<TermGroup>> fetch() => _service.fetchGroups();
}
