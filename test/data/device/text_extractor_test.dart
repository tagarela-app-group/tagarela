import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/text_extractor.dart';
import 'package:tagarela/data/models/models.dart';

import '../../helpers/fake_extraction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('on_device_extraction');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  late Object? Function(MethodCall) reply;
  late FakeModelStorage models;
  late TextExtractor extractor;

  setUp(() {
    calls = [];
    reply = (_) => '';
    models = FakeModelStorage();
    extractor = TextExtractor(models);
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return reply(call);
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Matcher failsWith(ExtractionError error) => throwsA(
    isA<ExtractionException>().having((e) => e.error, 'error', error),
  );

  test('foto: lê o texto e junta linhas e espaços', () async {
    reply = (_) => '  MIND\nTHE   GAP \n';

    final text = await extractor.extract(CaptureSource.photo, File('f.jpg'));

    expect(text, 'MIND THE GAP');
    expect(calls.single.method, 'recognizeText');
    expect(calls.single.arguments, {'path': 'f.jpg'});
  });

  test('áudio: transcreve com o modelo baixado', () async {
    models.path = '/app/models/tiny-streaming-en';
    reply = (_) => 'Mind the gap.';

    final text = await extractor.extract(CaptureSource.audio, File('a.m4a'));

    expect(text, 'Mind the gap.');
    expect(calls.single.method, 'transcribe');
    expect(calls.single.arguments, {
      'path': 'a.m4a',
      'modelPath': '/app/models/tiny-streaming-en',
      'arch': 2,
    });
  });

  test('áudio sem modelo: modelMissing sem chamar o plugin', () async {
    await expectLater(
      extractor.extract(CaptureSource.audio, File('a.m4a')),
      failsWith(ExtractionError.modelMissing),
    );
    expect(calls, isEmpty);
  });

  test('nada lido: noText', () async {
    reply = (_) => ' \n ';

    await expectLater(
      extractor.extract(CaptureSource.photo, File('f.jpg')),
      failsWith(ExtractionError.noText),
    );
  });

  test('erro do plugin ou plugin ausente: failed', () async {
    reply = (_) => throw PlatformException(code: 'extraction_failed');
    await expectLater(
      extractor.extract(CaptureSource.photo, File('f.jpg')),
      failsWith(ExtractionError.failed),
    );

    messenger.setMockMethodCallHandler(channel, null);
    await expectLater(
      extractor.extract(CaptureSource.photo, File('f.jpg')),
      failsWith(ExtractionError.failed),
    );
  });

  test('texto longo: corta na última palavra que cabe no limite', () async {
    reply = (_) => List.filled(500, 'word').join(' ');

    final text = await extractor.extract(CaptureSource.photo, File('f.jpg'));

    expect(text.length, 1999);
    expect(text.length, lessThanOrEqualTo(Capture.maxTextLength));
    expect(text, endsWith('word'));
  });

  test('release chama o plugin e ignora erro', () async {
    reply = (_) => throw PlatformException(code: 'extraction_failed');

    await extractor.release();

    expect(calls.single.method, 'release');
  });
}
