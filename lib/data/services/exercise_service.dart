import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';

class ExerciseService {
  const ExerciseService(this._api);

  final ApiClient _api;

  Future<List<Exercise>> forTerm(String termId, ExerciseKind kind) async {
    final json =
        await _api.get(
              '/api/v1/terms/$termId/exercises/${kind.key}',
              timeout: ApiClient.aiTimeout,
            )
            as Json;
    return [
      for (final exercise in (json['exercises']! as List).cast<Json>())
        ?Exercise.fromJson(exercise),
    ];
  }
}
