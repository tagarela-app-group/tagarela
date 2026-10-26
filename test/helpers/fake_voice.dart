import 'package:flutter/foundation.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';

class FakeVoice extends ChangeNotifier implements Voice {
  final spoken = <(String, CourseLanguage, VoiceSpeed)>[];
  final conversations = <List<String>>[];
  var stops = 0;

  @override
  VoiceSpeed? speaking;

  @override
  String? text;

  @override
  int? line;

  @override
  (int, int)? word;

  @override
  Future<void> speak(
    String text,
    CourseLanguage language, {
    VoiceSpeed speed = VoiceSpeed.normal,
  }) async {
    spoken.add((text, language, speed));
    speaking = speed;
    this.text = text;
    line = null;
    word = null;
    notifyListeners();
  }

  @override
  Future<void> speakLines(List<String> lines, CourseLanguage language) async {
    conversations.add(lines);
    speaking = VoiceSpeed.normal;
    text = lines.first;
    line = 0;
    word = null;
    notifyListeners();
  }

  void say(String text, {int? line, (int, int)? word}) {
    this.text = text;
    this.line = line;
    this.word = word;
    notifyListeners();
  }

  @override
  Future<void> stop() async {
    stops++;
    speaking = null;
    text = null;
    line = null;
    word = null;
    notifyListeners();
  }
}
