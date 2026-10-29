import 'package:flutter/services.dart';

enum MoonshineArch {
  tinyStreaming(2);

  const MoonshineArch(this.code);

  final int code;
}

class OnDeviceExtraction {
  const OnDeviceExtraction();

  static const _channel = MethodChannel('on_device_extraction');

  Future<String> recognizeText(String imagePath) async =>
      await _channel.invokeMethod<String>('recognizeText', {
        'path': imagePath,
      }) ??
      '';

  Future<String> transcribe(
    String audioPath, {
    required String modelPath,
    required MoonshineArch arch,
  }) async =>
      await _channel.invokeMethod<String>('transcribe', {
        'path': audioPath,
        'modelPath': modelPath,
        'arch': arch.code,
      }) ??
      '';

  Future<void> release() => _channel.invokeMethod<void>('release');
}
