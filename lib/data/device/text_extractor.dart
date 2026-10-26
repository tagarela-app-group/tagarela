import 'dart:io';

import 'package:flutter/services.dart';
import 'package:on_device_extraction/on_device_extraction.dart';

import 'package:tagarela/data/device/speech_model.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/storage/model_storage.dart';

enum ExtractionError {
  noText('no_text'),
  modelMissing('model_missing'),
  failed('extraction_failed');

  const ExtractionError(this.code);

  final String code;
}

class ExtractionException implements Exception {
  const ExtractionException(this.error);

  final ExtractionError error;
}

class TextExtractor {
  TextExtractor(
    this._models, {
    this._plugin = const OnDeviceExtraction(),
    this._model = SpeechModel.current,
  });

  final ModelStorage _models;
  final OnDeviceExtraction _plugin;
  final SpeechModel _model;

  Future<String> extract(CaptureSource source, File file) async {
    final String raw;
    try {
      raw = switch (source) {
        CaptureSource.photo => await _plugin.recognizeText(file.path),
        CaptureSource.audio => await _transcribe(file),
        CaptureSource.text => throw ArgumentError.value(source, 'source'),
      };
    } on PlatformException {
      throw const ExtractionException(ExtractionError.failed);
    } on MissingPluginException {
      throw const ExtractionException(ExtractionError.failed);
    }
    final text = _fit(raw.split(RegExp(r'\s+')).where((w) => w.isNotEmpty));
    if (text.isEmpty) throw const ExtractionException(ExtractionError.noText);
    return text;
  }

  Future<void> release() async {
    try {
      await _plugin.release();
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  Future<String> _transcribe(File file) async {
    final path = await _models.installed(_model);
    if (path == null) {
      throw const ExtractionException(ExtractionError.modelMissing);
    }
    return _plugin.transcribe(file.path, modelPath: path, arch: _model.arch);
  }

  static String _fit(Iterable<String> words) {
    final text = StringBuffer();
    for (final word in words) {
      final extra = text.isEmpty ? word.length : word.length + 1;
      if (text.length + extra > Capture.maxTextLength) break;
      if (text.isNotEmpty) text.write(' ');
      text.write(word);
    }
    return text.toString();
  }
}
