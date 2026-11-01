import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';

class ReviewService {
  const ReviewService(this._api);

  final ApiClient _api;

  Future<ReviewSession> session(
    Iterable<ExerciseKind> kinds,
    DateTime now,
  ) async {
    final query = [
      for (final kind in kinds) 'kinds=${kind.key}',
      'date=${dayKey(now)}',
      'offset=${now.timeZoneOffset.inMinutes}',
    ].join('&');
    return ReviewSession.fromJson(
      await _api.get('/api/v1/reviews?$query') as Json,
    );
  }

  Future<ReviewEffect> record(ReviewAttempt attempt) async {
    final play = attempt.play;
    final response =
        await _api.post('/api/v1/reviews/attempts', {
              'id': attempt.id,
              'term': attempt.term,
              'kind': attempt.kind.key,
              'exercise': attempt.exercise,
              'outcome': play.outcome.name,
              'used_slow': play.usedSlow,
              'errors': play.errors,
              'hints': play.hints,
              'audio_replays': play.audioReplays,
              'response_ms': ?play.responseMs,
              'played_at': ?attempt.playedAt?.toUtc().toIso8601String(),
              'local_date': ?attempt.localDate,
            })
            as Json;
    return ReviewEffect.fromJson(response['effect']! as Json);
  }

  Future<void> askForMore() => _api.post('/api/v1/reviews/more', const {});

  Future<void> study(String termId, StudyEvent event) =>
      _api.post('/api/v1/terms/$termId/study', {'event': event.name});
}
