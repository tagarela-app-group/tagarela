import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/daily_word_service.dart';
import 'package:tagarela/data/stores/store.dart';

class DailyWordStore extends Store<DailyWord> {
  DailyWordStore(
    this._service, {
    required this.onSaved,
    this._now = DateTime.now,
  });

  final DailyWordService _service;
  final Future<void> Function() onSaved;
  final DateTime Function() _now;
  DateTime? _day;

  DateTime get _today {
    final now = _now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Future<DailyWord> fetch() {
    _day = _today;
    return _service.today();
  }

  Future<void> refreshDay() async {
    if (_day == _today && error == null) return;
    clear();
    await load();
  }

  Future<void> save() async {
    emit(await guard(_service.save));
    await onSaved();
  }
}
