import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/store.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';

class VocabularyStore extends Store<Vocabulary> {
  VocabularyStore(this._service);

  final VocabularyService _service;

  @override
  Future<Vocabulary> fetch() => _service.fetch();

  Future<TermDetail> term(String id) => _service.term(id);

  Future<TermDetail> reveal(String id, {required bool revealed}) =>
      _service.reveal(id, revealed: revealed);

  Future<TermGroup> createGroup({
    required String name,
    required GroupIcon icon,
    required AppAccent accent,
  }) async {
    final group = await _service.createGroup(
      name: name,
      icon: icon,
      accent: accent,
    );
    emit((data ?? const Vocabulary()).withGroup(group));
    return group;
  }

  Future<TermGroup> updateGroup(
    String id, {
    required String name,
    required GroupIcon icon,
    required AppAccent accent,
  }) async {
    final group = await _service.updateGroup(
      id,
      name: name,
      icon: icon,
      accent: accent,
    );
    emit((data ?? const Vocabulary()).withGroup(group));
    return group;
  }

  Future<void> deleteGroup(String id) async =>
      emit(await _service.deleteGroup(id));

  Future<void> move(List<String> termIds, String? groupId) async =>
      emit(await _service.move(termIds, groupId));

  Future<void> deleteTerms(List<String> termIds) async =>
      emit(await _service.deleteTerms(termIds));

  Future<void> restoreTerms(List<String> termIds) async =>
      emit(await _service.restoreTerms(termIds));
}
