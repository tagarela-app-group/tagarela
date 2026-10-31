import 'package:flutter/foundation.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

enum GroupChange { moving, deleting }

class GroupController extends ChangeNotifier {
  GroupController(this._vocabulary);

  static const filters = [null, TermStatus.learning, TermStatus.mastered];

  final VocabularyStore _vocabulary;
  var _filter = 0;
  Set<String>? _selected;
  GroupChange? _change;
  var _disposed = false;

  int get filter => _filter;
  TermStatus? get status => filters[_filter];
  Set<String>? get selected => _selected;
  GroupChange? get change => _change;

  void showFilter(int index) {
    _filter = index;
    notifyListeners();
  }

  void select(Set<String>? selected) {
    _selected = selected;
    notifyListeners();
  }

  void toggle(String id) {
    final selected = {...?_selected};
    if (!selected.remove(id)) selected.add(id);
    select(selected);
  }

  void selectAll(Iterable<Term> terms) =>
      select({...?_selected, for (final term in terms) term.id});

  List<String> selectedIn(List<Term> terms) => [
    for (final term in terms)
      if (_selected?.contains(term.id) ?? false) term.id,
  ];

  Future<bool> move(List<String> ids, String? groupId) =>
      _apply(GroupChange.moving, () => _vocabulary.move(ids, groupId));

  Future<bool> delete(List<String> ids) =>
      _apply(GroupChange.deleting, () => _vocabulary.deleteTerms(ids));

  Future<bool> _apply(
    GroupChange change,
    Future<void> Function() action,
  ) async {
    _change = change;
    notifyListeners();
    var done = false;
    try {
      await action();
      done = true;
    } on Exception {
      done = false;
    }
    if (_disposed) return false;
    _change = null;
    if (done) _selected = null;
    notifyListeners();
    return done;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
