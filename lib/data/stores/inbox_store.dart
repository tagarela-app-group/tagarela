import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/inbox_service.dart';
import 'package:tagarela/data/store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

class InboxStore extends Store<List<InboxItem>> {
  InboxStore(this._service, {required this._vocabulary});

  final InboxService _service;

  /// Recarregado ao aceitar item (termo novo entra num grupo).
  final VocabularyStore _vocabulary;

  @override
  Future<List<InboxItem>> fetch() => _service.fetchItems();

  /// Falha da API sobe para a tela; item fica no Inbox.
  Future<void> accept(InboxItem item) async {
    await _service.accept(item);
    _remove(item);
    await _vocabulary.load();
  }

  Future<void> discard(InboxItem item) async {
    await _service.discard(item);
    _remove(item);
  }

  void _remove(InboxItem item) =>
      emit([...?data]..removeWhere((i) => i.id == item.id));
}
