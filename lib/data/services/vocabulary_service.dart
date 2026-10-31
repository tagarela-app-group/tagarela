import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';

class VocabularyService {
  const VocabularyService(this._api);

  final ApiClient _api;

  Future<TermDetail> term(String id) async => TermDetail.fromJson(
    await _api.get('/api/v1/terms/$id', timeout: ApiClient.aiTimeout) as Json,
  );

  Future<TermDetail> reveal(
    String id, {
    bool? revealed,
    bool? pitfallRevealed,
    bool? formalityRevealed,
  }) async => TermDetail.fromJson(
    await _api.patch('/api/v1/terms/$id', {
          'revealed': ?revealed,
          'pitfall_revealed': ?pitfallRevealed,
          'formality_revealed': ?formalityRevealed,
        })
        as Json,
  );

  Future<Vocabulary> fetch() async =>
      Vocabulary.fromJson(await _api.get('/api/v1/vocabulary') as Json);

  Future<TermGroup> createGroup({
    required String name,
    required GroupIcon icon,
    required GroupColor color,
  }) async => TermGroup.fromJson(
    await _api.post('/api/v1/groups', {
          'name': name,
          'icon': icon.name,
          'accent': color.name,
        })
        as Json,
  );

  Future<TermGroup> updateGroup(
    String id, {
    required String name,
    required GroupIcon icon,
    required GroupColor color,
  }) async => TermGroup.fromJson(
    await _api.patch('/api/v1/groups/$id', {
          'name': name,
          'icon': icon.name,
          'accent': color.name,
        })
        as Json,
  );

  Future<Vocabulary> deleteGroup(String id) async =>
      Vocabulary.fromJson(await _api.delete('/api/v1/groups/$id') as Json);

  Future<Vocabulary> move(List<String> termIds, String? groupId) async =>
      Vocabulary.fromJson(
        await _api.post('/api/v1/terms/move', {
              'terms': termIds,
              'group': groupId,
            })
            as Json,
      );

  Future<Vocabulary> deleteTerms(List<String> termIds) async =>
      Vocabulary.fromJson(
        await _api.post('/api/v1/terms/delete', {'terms': termIds}) as Json,
      );

  Future<Vocabulary> restoreTerms(List<String> termIds) async =>
      Vocabulary.fromJson(
        await _api.post('/api/v1/terms/restore', {'terms': termIds}) as Json,
      );
}
