import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/speech_model.dart';

void main() {
  test(
    'todo arquivo do modelo tem sha256 completo pra conferir o download',
    () {
      expect(
        SpeechModel.current.files.map((f) => f.sha256),
        everyElement(matches(RegExp(r'^[0-9a-f]{64}$'))),
      );
    },
  );
}
