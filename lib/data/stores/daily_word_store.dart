import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/daily_word_service.dart';
import 'package:tagarela/data/stores/store.dart';

class DailyWordStore extends Store<DailyWord> {
  DailyWordStore(this._service, {required this.onSaved});

  final DailyWordService _service;
  final Future<void> Function() onSaved;

  @override
  Future<DailyWord> fetch() => _service.today();

  Future<void> save() async {
    emit(await guard(_service.save));
    await onSaved();
  }
}
