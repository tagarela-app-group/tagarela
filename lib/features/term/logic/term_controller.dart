import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

enum TermTab { context, words, usage }

enum TermNote { remember, pitfall, formality }

class TermController extends ChangeNotifier {
  TermController(this._vocabulary, this._id);

  final VocabularyStore _vocabulary;
  final String _id;
  final _revealed = <TermNote>{};
  final _bursts = {for (final note in TermNote.values) note: 0};
  TermDetail? _detail;
  Object? _error;
  var _flipped = false;
  var _asked = false;
  var _tab = TermTab.context;
  var _disposed = false;

  TermDetail? get detail => _detail;
  Object? get error => _error;
  bool get flipped => _flipped;
  bool get asked => _asked;

  bool revealed(TermNote note) => _revealed.contains(note);

  int bursts(TermNote note) => _bursts[note]!;

  List<TermTab> get tabs {
    final detail = _detail;
    if (detail == null) return const [];
    final card = detail.card;
    return [
      if (detail.captures.isNotEmpty ||
          card.dialogue.isNotEmpty ||
          card.examples.isNotEmpty)
        TermTab.context,
      if (card.hasWords) TermTab.words,
      if (card.hasUsage) TermTab.usage,
    ];
  }

  TermTab? get tab {
    final tabs = this.tabs;
    return tabs.contains(_tab) ? _tab : tabs.firstOrNull;
  }

  Future<void> load() async {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
    try {
      final detail = await _vocabulary.term(_id);
      if (_disposed) return;
      _detail = detail;
      _revealed
        ..clear()
        ..addAll({
          if (detail.revealed) TermNote.remember,
          if (detail.pitfallRevealed) TermNote.pitfall,
          if (detail.formalityRevealed) TermNote.formality,
        });
    } on Exception catch (e) {
      if (_disposed) return;
      _error = e;
    }
    notifyListeners();
  }

  void reveal(TermNote note, {required bool revealed}) {
    if (revealed == this.revealed(note)) return;
    if (revealed) {
      _revealed.add(note);
      _bursts[note] = bursts(note) + 1;
    } else {
      _revealed.remove(note);
    }
    if (note == TermNote.remember) _asked = revealed;
    notifyListeners();
    unawaited(_save(note, revealed));
  }

  void flip() {
    _flipped = !_flipped;
    notifyListeners();
  }

  void select(TermTab tab) {
    _tab = tab;
    notifyListeners();
  }

  Future<void> _save(TermNote note, bool revealed) async {
    try {
      await _vocabulary.reveal(
        _id,
        revealed: note == TermNote.remember ? revealed : null,
        pitfallRevealed: note == TermNote.pitfall ? revealed : null,
        formalityRevealed: note == TermNote.formality ? revealed : null,
      );
    } on Exception {
      return;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
