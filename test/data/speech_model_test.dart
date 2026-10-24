import 'package:flutter_test/flutter_test.dart';
import 'package:on_device_extraction/on_device_extraction.dart';

import 'package:tagarela/data/speech_model.dart';

void main() {
  test('modelo atual: Tiny Streaming, 8 arquivos, 45 MB', () {
    const model = SpeechModel.current;

    expect(model.id, 'tiny-streaming-en');
    expect(model.arch, MoonshineArch.tinyStreaming);
    expect(model.files, hasLength(8));
    expect(model.size, 45233659);
    expect(model.sizeLabel, '45 MB');
    expect(
      model.files.map((f) => f.sha256),
      everyElement(matches(RegExp(r'^[0-9a-f]{64}$'))),
    );
  });

  test('URL fixa no commit do repositório de modelos', () {
    const model = SpeechModel.current;

    expect(
      model.url(model.files.first).toString(),
      'https://huggingface.co/moonshine-ai/moonshine-voice-assets/resolve/'
      '0bf2f2e5aff22e6fbba4300b00a4e00bbc4f8aae/model/tiny-streaming-en/'
      'quantized_26_08_21/adapter.ort',
    );
  });
}
