import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';

class VocabularyService {
  const VocabularyService(this._api);

  static const cardTimeout = Duration(seconds: 45);

  final ApiClient _api;

  Future<TermDetail> term(String id) async => TermDetail.fromJson(
    await _api.get('/api/v1/terms/$id', timeout: cardTimeout) as Json,
  );

  Future<TermDetail> reveal(String id, {required bool revealed}) async =>
      TermDetail.fromJson(
        await _api.patch('/api/v1/terms/$id', {'revealed': revealed}) as Json,
      );

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

  Future<TermGroup> updateGroup(
    String id, {
    required String name,
    required GroupIcon icon,
    required AppAccent accent,
  }) async => TermGroup.fromJson(
    await _api.patch('/api/v1/groups/$id', {
          'name': name,
          'icon': icon.name,
          'accent': accent.name,
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
