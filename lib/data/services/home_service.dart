import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';

class HomeService {
  const HomeService(this._api);

  final ApiClient _api;

  Future<Stats> fetchStats() async =>
      Stats.fromJson(await _api.get('/stats') as Json);

  Future<WordOfDay> fetchWordOfDay() async =>
      WordOfDay.fromJson(await _api.get('/wordOfDay') as Json);
}
