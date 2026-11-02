import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';

class RoundListening {
  RoundListening(this.voice, this.language);

  final Voice voice;
  final CourseLanguage language;
  var usedSlow = false;
  var replays = 0;

  void play(String text, VoiceSpeed speed, {bool auto = false}) {
    if (voice.speaking == speed && voice.text == text) {
      voice.stop();
      return;
    }
    if (speed == VoiceSpeed.slow) usedSlow = true;
    if (!auto) replays++;
    voice.speak(text, language, speed: speed);
  }
}
