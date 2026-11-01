import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';

class DailyWordService {
  const DailyWordService(this._api);

  final ApiClient _api;

  Future<DailyWord> today() async =>
      DailyWord.fromJson(await _api.get('/api/v1/daily-word') as Json);

  Future<DailyWord> save() async => DailyWord.fromJson(
    await _api.post('/api/v1/daily-word/save', const {}) as Json,
  );
}
