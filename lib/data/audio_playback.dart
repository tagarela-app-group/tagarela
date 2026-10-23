import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioPlayback extends ChangeNotifier {
  AudioPlayer? _player;
  String? _playing;
  Duration _position = Duration.zero;
  Duration? _total;

  String? get playing => _playing;
  Duration get position => _position;
  Duration? get total => _total;

  Future<void> toggle(File file) async {
    final player = _player ??= _create();
    await player.stop();
    if (_playing == file.path) return _reset();
    _playing = file.path;
    _position = Duration.zero;
    _total = null;
    notifyListeners();
    await player.play(DeviceFileSource(file.path));
  }

  Future<Duration?> duration(File file) async {
    final probe = AudioPlayer();
    try {
      await probe.setSource(DeviceFileSource(file.path));
      return await probe.getDuration();
    } finally {
      await probe.dispose();
    }
  }

  AudioPlayer _create() => AudioPlayer()
    ..onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    })
    ..onDurationChanged.listen((total) {
      _total = total;
      notifyListeners();
    })
    ..onPlayerComplete.listen((_) => _reset());

  void _reset() {
    _playing = null;
    _position = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}
