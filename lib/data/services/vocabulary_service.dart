import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';

class VocabularyService {
  const VocabularyService(this._api);

  final ApiClient _api;

  Future<List<TermGroup>> fetchGroups() async {
    final list = await _api.get('/groups?_embed=terms') as List<Object?>;
    return [for (final g in list) TermGroup.fromJson(g! as Json)];
  }
}
