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

  Future<void> record(ReviewAttempt attempt) =>
      _api.post('/api/v1/reviews/attempts', {
        'id': attempt.id,
        'term': attempt.term,
        'kind': attempt.kind.key,
        'exercise': attempt.exercise,
        'outcome': attempt.outcome.name,
      });
}
