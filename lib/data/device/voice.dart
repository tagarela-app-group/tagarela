import 'dart:async';

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
    ..setCompletionHandler(_next)
    ..setCancelHandler(_done)
    ..setErrorHandler((_) => _done())
    ..setProgressHandler(_progress);

  VoiceSpeed? _speaking;
  List<String> _lines = const [];
  int? _line;
  (int, int)? _word;

  VoiceSpeed? get speaking => _speaking;

  String? get text => _speaking == null ? null : _lines[_line ?? 0];

  int? get line => _lines.length > 1 ? _line : null;

  (int, int)? get word => _word;

  Future<void> speak(
    String text,
    CourseLanguage language, {
    VoiceSpeed speed = VoiceSpeed.normal,
  }) => _start([text], language, speed);

  Future<void> speakLines(List<String> lines, CourseLanguage language) =>
      _start(lines, language, VoiceSpeed.normal);

  Future<void> stop() async {
    await _tts.stop();
    _done();
  }

  Future<void> _start(
    List<String> lines,
    CourseLanguage language,
    VoiceSpeed speed,
  ) async {
    if (lines.isEmpty) return;
    await _tts.stop();
    _speaking = speed;
    _lines = lines;
    _line = 0;
    _word = null;
    notifyListeners();
    await _tts.setLanguage(_locales[language]!);
    await _tts.setSpeechRate(_rates[speed]!);
    await _tts.speak(lines.first);
  }

  void _progress(String text, int start, int end, String word) {
    if (_speaking == null) return;
    _word = (start, end);
    notifyListeners();
  }

  void _next() {
    final line = _line;
    if (_speaking == null || line == null || line + 1 >= _lines.length) {
      return _done();
    }
    _line = line + 1;
    _word = null;
    notifyListeners();
    unawaited(_tts.speak(_lines[line + 1]));
  }

  void _done() {
    if (_speaking == null) return;
    _speaking = null;
    _lines = const [];
    _line = null;
    _word = null;
    notifyListeners();
  }
}
