import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';

import '../../helpers/contract.dart';

void main() {
  test('captura', () {
    final capture = Capture.fromJson(contractExample('capture'));

    expect(capture.status, CaptureStatus.analyzed);
    expect(capture.terms.single.text, 'mind the gap');
    expect(capture.analyzedAt, isNotNull);
  });

  test('curso', () {
    final course = Course.fromJson(contractExample('course'));

    expect(course.learning, CourseLanguage.en);
    expect(course.terms, 2);
  });

  test('vocabulário', () {
    final vocabulary = Vocabulary.fromJson(contractExample('vocabulary'));

    expect(vocabulary.groups.single.terms.single.text, 'mind the gap');
    expect(vocabulary.ungrouped.single.text, 'awkward');
  });

  test('ficha do termo', () {
    final detail = TermDetail.fromJson(contractExample('term_detail'));

    expect(detail.term.text, 'mind the gap');
    expect(detail.group?.name, 'Viagem');
    expect(detail.card.mistake?.right, 'mind the gap');
    expect(detail.card.fits, hasLength(2));
    expect(detail.captures.single.spans.single.end, 19);
  });

  test('exercícios', () {
    final exercises =
        contractExample('exercises')['exercises']! as List<Object?>;
    final exercise = Exercise.fromJson(exercises.single! as Json);

    expect(
      exercise,
      isA<ListenWriteExercise>().having(
        (e) => e.answer,
        'answer',
        'on the fence',
      ),
    );
  });

  test('revisão', () {
    final session = ReviewSession.fromJson(contractExample('review_session'));

    expect(session.due, 1);
    expect(session.rounds.single.kind, ExerciseKind.listenWrite);
  });

  test('tentativa de revisão', () {
    final json = contractExample('review_attempt');

    expect(Term.fromJson(json['term']! as Json).level, 3);
  });

  test('conta', () {
    expect(User.fromJson(contractExample('account')).country, 'BR');
  });

  test('valores de enum que o app aceita', () {
    final enums = contractExample('enums');
    List<String> values(String key) =>
        (enums[key]! as List<Object?>).cast<String>();

    expect(
      values('capture_source'),
      unorderedEquals(CaptureSource.values.map((s) => s.name)),
    );
    expect(
      values('capture_status'),
      unorderedEquals(CaptureStatus.values.map((s) => s.apiName)),
    );
    expect(
      values('course_language'),
      unorderedEquals(CourseLanguage.values.map((l) => l.name)),
    );
    expect(
      values('term_kind'),
      unorderedEquals(TermKind.values.map((k) => k.name)),
    );
  });
}
