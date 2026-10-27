import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';

class ReviewService {
  const ReviewService(this._api);

  final ApiClient _api;

  Future<ReviewSession> session(Iterable<ExerciseKind> kinds) async {
    final query = [for (final kind in kinds) 'kinds=${kind.key}'].join('&');
    return ReviewSession.fromJson(
      await _api.get('/api/v1/reviews?$query') as Json,
    );
  }

  Future<Term> record({
    required String termId,
    required ExerciseKind kind,
    required String? exerciseId,
    required Outcome outcome,
  }) async {
    final json =
        await _api.post('/api/v1/reviews/attempts', {
              'term': termId,
              'kind': kind.key,
              'exercise': exerciseId,
              'outcome': outcome.name,
            })
            as Json;
    return Term.fromJson(json['term']! as Json);
  }
}
