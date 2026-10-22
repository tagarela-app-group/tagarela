import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';

class InboxService {
  const InboxService(this._api);

  final ApiClient _api;

  Future<List<InboxItem>> fetchItems() async {
    final list = await _api.get('/inbox') as List<Object?>;
    return [for (final i in list) InboxItem.fromJson(i! as Json)];
  }

  /// Vira termo no grupo sugerido e sai do Inbox.
  /// json-server não tem ação composta: são duas chamadas.
  /// API real: trocar por um endpoint só (ex.: `POST /inbox/:id/accept`).
  Future<void> accept(InboxItem item) async {
    final suggestion = item.suggestion!;
    await _api.post('/terms', {
      'groupId': suggestion.groupId,
      'text': item.content,
      'translation': suggestion.translation,
      'kind': suggestion.kind.name,
      'level': 0,
    });
    await discard(item);
  }

  Future<void> discard(InboxItem item) => _api.delete('/inbox/${item.id}');
}
