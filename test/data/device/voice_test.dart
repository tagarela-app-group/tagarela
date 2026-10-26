import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_tts');
  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return 1;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<void> send(String method, [Object? arguments]) =>
      messenger.handlePlatformMessage(
        channel.name,
        const StandardMethodCodec().encodeMethodCall(
          MethodCall(method, arguments),
        ),
        (_) {},
      );

  Future<void> finish() => send('speak.onComplete');

  test('fala no idioma do curso e na velocidade pedida', () async {
    final voice = Voice();

    await voice.speak('hola', CourseLanguage.es, speed: VoiceSpeed.slow);

    expect(
      [for (final c in calls) (c.method, c.arguments)],
      containsAllInOrder([
        ('stop', null),
        ('setLanguage', 'es-ES'),
        ('setSpeechRate', 0.25),
      ]),
    );
    expect(calls.last.method, 'speak');
    expect(voice.speaking, VoiceSpeed.slow);
  });

  test('ao terminar volta a ficar quieta e avisa', () async {
    final voice = Voice();
    var notified = 0;
    voice.addListener(() => notified++);

    await voice.speak('gap', CourseLanguage.en);
    await finish();

    expect(voice.speaking, isNull);
    expect(notified, 2);
  });

  test('parar cala e limpa o estado', () async {
    final voice = Voice();
    await voice.speak('gap', CourseLanguage.pt);

    await voice.stop();

    expect(calls.last.method, 'stop');
    expect(voice.speaking, isNull);
    expect(
      calls.where((c) => c.method == 'setLanguage').single.arguments,
      'pt-BR',
    );
  });

  test('acompanha a palavra que está sendo falada', () async {
    final voice = Voice();
    await voice.speak('on the fence', CourseLanguage.en);

    await send('speak.onProgress', {
      'text': 'on the fence',
      'start': 3,
      'end': 6,
      'word': 'the',
    });

    expect(voice.text, 'on the fence');
    expect(voice.word, (3, 6));
    expect(voice.line, isNull);

    await finish();

    expect(voice.word, isNull);
    expect(voice.text, isNull);
  });

  test('conversa fala uma fala depois da outra', () async {
    final voice = Voice();

    await voice.speakLines([
      'Are you in?',
      'Still on the fence.',
    ], CourseLanguage.en);

    expect(voice.line, 0);
    expect(calls.last.arguments, 'Are you in?');

    await finish();

    expect(voice.line, 1);
    expect(voice.text, 'Still on the fence.');
    expect(calls.last.arguments, 'Still on the fence.');

    await finish();

    expect(voice.speaking, isNull);
    expect(voice.line, isNull);
  });

  test('parar no meio da conversa não segue pra próxima fala', () async {
    final voice = Voice();
    await voice.speakLines(['one', 'two'], CourseLanguage.en);

    await voice.stop();
    await finish();

    expect(voice.speaking, isNull);
    expect(calls.where((c) => c.method == 'speak').length, 1);
  });
}
