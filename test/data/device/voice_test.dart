import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';

class _FakeTts extends Fake implements FlutterTts {
  final spoken = <String>[];
  late VoidCallback finish;
  late ProgressHandler progress;

  @override
  void setCompletionHandler(VoidCallback callback) => finish = callback;

  @override
  void setProgressHandler(ProgressHandler callback) => progress = callback;

  @override
  void setCancelHandler(VoidCallback callback) {}

  @override
  void setErrorHandler(ErrorHandler handler) {}

  @override
  Future<Object?> setLanguage(String language) async => 1;

  @override
  Future<Object?> setSpeechRate(double rate) async => 1;

  @override
  Future<Object?> stop() async => 1;

  @override
  Future<Object?> speak(String text, {bool focus = false}) async {
    spoken.add(text);
    return 1;
  }
}

void main() {
  late _FakeTts tts;
  late Voice voice;

  setUp(() {
    tts = _FakeTts();
    voice = Voice(tts);
  });

  test('fala e guarda a velocidade pedida', () async {
    await voice.speak('hola', CourseLanguage.es, speed: VoiceSpeed.slow);

    expect(tts.spoken, ['hola']);
    expect(voice.speaking, VoiceSpeed.slow);
  });

  test('ao terminar volta a ficar quieta e avisa', () async {
    var notified = 0;
    voice.addListener(() => notified++);

    await voice.speak('gap', CourseLanguage.en);
    tts.finish();

    expect(voice.speaking, isNull);
    expect(notified, 2);
  });

  test('parar limpa o estado', () async {
    await voice.speak('gap', CourseLanguage.pt);

    await voice.stop();

    expect(voice.speaking, isNull);
  });

  test('acompanha a palavra que está sendo falada', () async {
    await voice.speak('on the fence', CourseLanguage.en);

    tts.progress('on the fence', 3, 6, 'the');

    expect(voice.text, 'on the fence');
    expect(voice.word, (3, 6));
    expect(voice.line, isNull);

    tts.finish();

    expect(voice.word, isNull);
    expect(voice.text, isNull);
  });

  test('conversa fala uma fala depois da outra', () async {
    await voice.speakLines([
      'Are you in?',
      'Still on the fence.',
    ], CourseLanguage.en);

    expect(voice.line, 0);
    expect(tts.spoken.last, 'Are you in?');

    tts.finish();

    expect(voice.line, 1);
    expect(voice.text, 'Still on the fence.');
    expect(tts.spoken.last, 'Still on the fence.');

    tts.finish();

    expect(voice.speaking, isNull);
    expect(voice.line, isNull);
  });

  test('parar no meio da conversa não segue pra próxima fala', () async {
    await voice.speakLines(['one', 'two'], CourseLanguage.en);

    await voice.stop();
    tts.finish();

    expect(voice.speaking, isNull);
    expect(tts.spoken, ['one']);
  });
}
