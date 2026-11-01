import 'dart:io';
import 'dart:ui' as ui;

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

  Future<ui.Size?> imageSize(File file) async {
    try {
      final image = await _decode(file);
      final size = ui.Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      return size;
    } on Exception {
      return null;
    }
  }

  Future<File> crop(File file, ui.Rect area) async {
    final image = await _decode(file);
    final source = ui.Rect.fromLTRB(
      (area.left * image.width).floorToDouble(),
      (area.top * image.height).floorToDouble(),
      (area.right * image.width).ceilToDouble(),
      (area.bottom * image.height).ceilToDouble(),
    );
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawImageRect(image, source, ui.Offset.zero & source.size, ui.Paint());
    final picture = recorder.endRecording();
    final cropped = await picture.toImage(
      source.width.toInt(),
      source.height.toInt(),
    );
    final bytes = await cropped.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    cropped.dispose();
    final dir = await getTemporaryDirectory();
    final target = File(
      '${dir.path}/recorte-${DateTime.now().millisecondsSinceEpoch}.png',
    );
    return target.writeAsBytes(bytes!.buffer.asUint8List());
  }

  Future<ui.Image> _decode(File file) async {
    final codec = await ui.instantiateImageCodec(await file.readAsBytes());
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
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
