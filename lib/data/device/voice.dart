import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:tagarela/data/models/models.dart';

enum VoiceSpeed { normal, slow }

class Voice extends ChangeNotifier {
  Voice([FlutterTts? tts]) : _given = tts;

  static const _locales = {
    CourseLanguage.en: 'en-US',
    CourseLanguage.es: 'es-ES',
    CourseLanguage.pt: 'pt-BR',
  };

  static const _rates = {VoiceSpeed.normal: 0.5, VoiceSpeed.slow: 0.25};

  final FlutterTts? _given;
  late final FlutterTts _tts = (_given ?? FlutterTts())
    ..setCompletionHandler(_done)
    ..setCancelHandler(_done)
    ..setErrorHandler((_) => _done());

  VoiceSpeed? _speaking;

  VoiceSpeed? get speaking => _speaking;

  Future<void> speak(
    String text,
    CourseLanguage language, {
    VoiceSpeed speed = VoiceSpeed.normal,
  }) async {
    await _tts.stop();
    _speaking = speed;
    notifyListeners();
    await _tts.setLanguage(_locales[language]!);
    await _tts.setSpeechRate(_rates[speed]!);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _done();
  }

  void _done() {
    if (_speaking == null) return;
    _speaking = null;
    notifyListeners();
  }
}
