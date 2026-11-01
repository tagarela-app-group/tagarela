import 'dart:async';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/stores/store.dart';

class VocabularyStore extends Store<Vocabulary> {
  VocabularyStore(this._service, {this._onTermsChanged});

  final VocabularyService _service;
  final Future<void> Function()? _onTermsChanged;

  @override
  Future<Vocabulary> fetch() => _service.fetch();

  Future<void> refresh() async {
    await Future.wait([
      load(),
      if (_onTermsChanged case final reload?) reload(),
    ]);
  }

  Future<TermDetail> term(String id) => _service.term(id);

  Future<TermDetail> reveal(
    String id, {
    bool? revealed,
    bool? pitfallRevealed,
    bool? formalityRevealed,
    bool? gotIt,
  }) => _service.reveal(
    id,
    revealed: revealed,
    pitfallRevealed: pitfallRevealed,
    formalityRevealed: formalityRevealed,
    gotIt: gotIt,
  );

  Future<TermGroup> createGroup({
    required String name,
    required GroupIcon icon,
    required GroupColor color,
  }) async {
    final group = await guard(
      () => _service.createGroup(name: name, icon: icon, color: color),
    );
    emit((data ?? const Vocabulary()).withGroup(group));
    return group;
  }

  Future<TermGroup> updateGroup(
    String id, {
    required String name,
    required GroupIcon icon,
    required GroupColor color,
  }) async {
    final group = await guard(
      () => _service.updateGroup(id, name: name, icon: icon, color: color),
    );
    emit((data ?? const Vocabulary()).withGroup(group));
    return group;
  }

  Future<void> deleteGroup(String id) async =>
      emit(await _service.deleteGroup(id));

  Future<void> move(List<String> termIds, String? groupId) async =>
      emit(await _service.move(termIds, groupId));

  Future<void> deleteTerms(List<String> termIds) async {
    emit(await _service.deleteTerms(termIds));
    _notifyTermsChanged();
  }

  Future<void> restoreTerms(List<String> termIds) async {
    emit(await _service.restoreTerms(termIds));
    _notifyTermsChanged();
  }

  void _notifyTermsChanged() {
    if (_onTermsChanged case final reload?) unawaited(reload());
  }
}
