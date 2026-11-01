import 'package:flutter/foundation.dart';

import 'package:tagarela/data/models/models.dart';

enum GapStatus { typing, wrong, solved, revealed }

class GapFill extends ChangeNotifier {
  GapFill(this.answer)
    : _typed = List<String?>.filled(answer.length, null),
      _hints = List<bool>.filled(answer.length, false),
      _wrong = List<bool>.filled(answer.length, false);

  static final _letter = RegExp(r'\p{L}', unicode: true);

  final String answer;
  final List<String?> _typed;
  final List<bool> _hints;
  final List<bool> _wrong;
  var _status = GapStatus.typing;
  var _tries = 0;

  GapStatus get status => _status;
  int get tries => _tries;
  bool get finished =>
      _status == GapStatus.solved || _status == GapStatus.revealed;

  bool isSlot(int i) => _letter.hasMatch(answer[i]);
  bool isHint(int i) => _hints[i];
  bool isWrong(int i) => _wrong[i];

  String? letterAt(int i) => finished ? answer[i] : _typed[i];

  Iterable<int> get _slots =>
      Iterable<int>.generate(answer.length).where(isSlot);

  int get letters => _slots.length;
  int get left => _slots.where((i) => _typed[i] == null).length;
  int get wrongCount => _wrong.where((w) => w).length;
  int get hintsUsed => _hints.where((h) => h).length;
  bool get complete => left == 0;

  int? get cursor =>
      finished ? null : _slots.where((i) => _typed[i] == null).firstOrNull;

  Outcome get outcome {
    if (_status == GapStatus.revealed) return Outcome.missed;
    if (_hints.contains(true)) return Outcome.hint;
    if (_tries > 0) return Outcome.retry;
    return Outcome.first;
  }

  void type(String letter) {
    if (finished) return;
    _clearWrong();
    if (cursor case final i?) _typed[i] = letter.toLowerCase();
    _status = GapStatus.typing;
    notifyListeners();
  }

  void erase() {
    if (finished) return;
    if (_wrong.contains(true)) {
      _clearWrong();
    } else {
      final typed = _slots.where((i) => _typed[i] != null && !_hints[i]);
      if (typed.lastOrNull case final i?) _typed[i] = null;
    }
    _status = GapStatus.typing;
    notifyListeners();
  }

  void hint() {
    if (finished) return;
    final i = _slots.where((i) => _typed[i] != _expected(i)).firstOrNull;
    if (i == null) return;
    _clearWrong();
    _typed[i] = _expected(i);
    _hints[i] = true;
    _status = GapStatus.typing;
    notifyListeners();
  }

  bool check() {
    if (finished || !complete) return false;
    for (final i in _slots) {
      _wrong[i] = _typed[i] != _expected(i);
    }
    if (_wrong.contains(true)) {
      _tries++;
      _status = GapStatus.wrong;
    } else {
      _status = GapStatus.solved;
    }
    notifyListeners();
    return _status == GapStatus.solved;
  }

  void reveal() {
    if (finished) return;
    _clearWrong();
    _status = GapStatus.revealed;
    notifyListeners();
  }

  String _expected(int i) => answer[i].toLowerCase();

  void _clearWrong() {
    for (final i in _slots) {
      if (_wrong[i]) {
        _typed[i] = null;
        _wrong[i] = false;
      }
    }
  }
}
