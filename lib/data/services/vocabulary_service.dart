import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';

class VocabularyService {
  const VocabularyService(this._api);

  final ApiClient _api;

  Future<Vocabulary> fetch() async =>
      Vocabulary.fromJson(await _api.get('/api/v1/vocabulary') as Json);

  Future<TermGroup> createGroup({
    required String name,
    required GroupIcon icon,
    required AppAccent accent,
  }) async => TermGroup.fromJson(
    await _api.post('/api/v1/groups', {
          'name': name,
          'icon': icon.name,
          'accent': accent.name,
        })
        as Json,
  );

  Future<Vocabulary> move(List<String> termIds, String? groupId) async =>
      Vocabulary.fromJson(
        await _api.post('/api/v1/terms/move', {
              'terms': termIds,
              'group': groupId,
            })
            as Json,
      );
}
