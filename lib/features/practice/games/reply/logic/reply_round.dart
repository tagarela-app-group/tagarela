import 'package:flutter/foundation.dart';

import 'package:tagarela/data/models/models.dart';

enum ReplyStatus { open, solved, revealed }

class ReplyRound extends ChangeNotifier {
  ReplyRound(this.answer);

  static const _missedAfter = 3;

  final String answer;
  final _wrongs = <String>[];
  var _status = ReplyStatus.open;

  List<String> get wrongs => List.unmodifiable(_wrongs);
  ReplyStatus get status => _status;
  bool get finished => _status != ReplyStatus.open;
  bool get canReveal => !finished && _wrongs.isNotEmpty;

  Outcome get outcome {
    if (_status == ReplyStatus.revealed || _wrongs.length >= _missedAfter) {
      return Outcome.missed;
    }
    return switch (_wrongs.length) {
      0 => Outcome.first,
      1 => Outcome.slip,
      _ => Outcome.retry,
    };
  }

  bool isUsed(String option) => _wrongs.contains(option);

  bool pick(String option) {
    if (finished || isUsed(option)) return false;
    if (option == answer) {
      _status = ReplyStatus.solved;
    } else {
      _wrongs.add(option);
    }
    notifyListeners();
    return _status == ReplyStatus.solved;
  }

  void reveal() {
    if (finished) return;
    _status = ReplyStatus.revealed;
    notifyListeners();
  }
}

String fitOption(String option, String before) {
  final startsSentence = before.isEmpty || RegExp(r'[.!?] $').hasMatch(before);
  if (!startsSentence || option.isEmpty) return option;
  return option[0].toUpperCase() + option.substring(1);
}
