import 'package:tagarela/data/models/json.dart';
import 'package:tagarela/data/models/text_offsets.dart';

enum ExerciseKind {
  listenWrite('listen_write'),
  reply('reply');

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
      ExerciseKind.reply => ReplyExercise.fromPayload(id, payload),
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
    int offset(String key) => codeUnitOffset(sentence, payload[key]! as int);
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

enum ReplyMode { use, understand, audio }

final class ReplyExercise extends Exercise {
  const ReplyExercise({
    required super.id,
    required this.mode,
    required this.segue,
    required this.nina,
    required this.reply,
    required this.start,
    required this.end,
    required this.ninaReply,
    required this.answer,
    required this.options,
    required super.translation,
    required super.extra,
  });

  factory ReplyExercise.fromPayload(String id, Json payload) {
    final reply = payload['reply']! as String;
    int offset(String key) => codeUnitOffset(reply, payload[key]! as int);
    return ReplyExercise(
      id: id,
      mode: ReplyMode.values.byName(payload['mode']! as String),
      segue: payload['segue']! as String,
      nina: payload['nina']! as String,
      reply: reply,
      start: offset('start'),
      end: offset('end'),
      ninaReply: payload['nina_reply']! as String,
      answer: payload['answer']! as String,
      options: (payload['options']! as List).cast<String>(),
      translation: payload['translation']! as String,
      extra: ExerciseExtra.fromJson(payload['extra']! as Json),
    );
  }

  final ReplyMode mode;
  final String segue;
  final String nina;
  final String reply;
  final int start;
  final int end;
  final String ninaReply;
  final String answer;
  final List<String> options;

  String get before => reply.substring(0, start);
  String get filled => reply.substring(start, end);
  String get after => reply.substring(end);

  String opening({required bool continuing}) =>
      continuing && segue.isNotEmpty ? '$segue $nina' : nina;

  @override
  ExerciseKind get kind => ExerciseKind.reply;
}
