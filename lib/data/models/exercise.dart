import 'package:tagarela/data/models/json.dart';

enum ExerciseKind {
  listenWrite('listen_write');

  const ExerciseKind(this.key);

  final String key;

  static ExerciseKind? fromKey(String key) =>
      values.where((kind) => kind.key == key).firstOrNull;
}

class ExerciseExtra {
  const ExerciseExtra({required this.note, required this.say});

  ExerciseExtra.fromJson(Json json)
    : this(note: json['note']! as String, say: json['say']! as String);

  final String note;
  final String say;
}

sealed class Exercise {
  const Exercise({
    required this.id,
    required this.translation,
    required this.extra,
  });

  final String id;
  final String translation;
  final ExerciseExtra extra;

  ExerciseKind get kind;

  static Exercise? fromJson(Json json) {
    final id = json['id']! as String;
    final payload = json['payload']! as Json;
    return switch (ExerciseKind.fromKey(json['kind']! as String)) {
      ExerciseKind.listenWrite => ListenWriteExercise.fromPayload(id, payload),
      null => null,
    };
  }
}

final class ListenWriteExercise extends Exercise {
  const ListenWriteExercise({
    required super.id,
    required this.sentence,
    required this.start,
    required this.end,
    required this.syllables,
    required super.translation,
    required super.extra,
  });

  factory ListenWriteExercise.fromPayload(String id, Json payload) {
    final sentence = payload['sentence']! as String;
    final runes = sentence.runes.toList();
    int offset(String key) =>
        String.fromCharCodes(runes.take(payload[key]! as int)).length;
    return ListenWriteExercise(
      id: id,
      sentence: sentence,
      start: offset('start'),
      end: offset('end'),
      syllables: payload['syllables']! as String,
      translation: payload['translation']! as String,
      extra: ExerciseExtra.fromJson(payload['extra']! as Json),
    );
  }

  final String sentence;
  final int start;
  final int end;
  final String syllables;

  String get answer => sentence.substring(start, end);

  @override
  ExerciseKind get kind => ExerciseKind.listenWrite;
}
