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

  Future<void> finish() => messenger.handlePlatformMessage(
    channel.name,
    const StandardMethodCodec().encodeMethodCall(
      const MethodCall('speak.onComplete'),
    ),
    (_) {},
  );

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
}
