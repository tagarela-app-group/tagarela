import 'package:flutter/foundation.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';

class FakeVoice extends ChangeNotifier implements Voice {
  final spoken = <(String, CourseLanguage, VoiceSpeed)>[];
  var stops = 0;

  @override
  VoiceSpeed? speaking;

  @override
  Future<void> speak(
    String text,
    CourseLanguage language, {
    VoiceSpeed speed = VoiceSpeed.normal,
  }) async {
    spoken.add((text, language, speed));
    speaking = speed;
    notifyListeners();
  }

  @override
  Future<void> stop() async {
    stops++;
    speaking = null;
    notifyListeners();
  }
}
