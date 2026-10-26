import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

enum PhotoOrigin { camera, gallery }

class CaptureDevice {
  static const maxRecording = Duration(seconds: 60);

  AudioRecorder? _recorder;

  Future<bool> allowCamera() => _allow(Permission.camera);

  Future<bool> allowMicrophone() => _allow(Permission.microphone);

  Future<void> openSettings() => openAppSettings();

  Future<File?> photo(PhotoOrigin origin) async {
    final picked = await ImagePicker().pickImage(
      source: switch (origin) {
        PhotoOrigin.camera => ImageSource.camera,
        PhotoOrigin.gallery => ImageSource.gallery,
      },
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 85,
    );
    return picked == null ? null : File(picked.path);
  }

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    await (_recorder ??= AudioRecorder()).start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 48000,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: '${dir.path}/gravacao-${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
  }

  Future<File?> stopRecording() async {
    final path = await _recorder?.stop();
    return path == null ? null : File(path);
  }

  Future<void> cancelRecording() async => _recorder?.cancel();

  Future<void> discard(File file) async {
    try {
      await file.delete();
    } on FileSystemException {
      return;
    }
  }

  Future<bool> _allow(Permission permission) async {
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }
}
