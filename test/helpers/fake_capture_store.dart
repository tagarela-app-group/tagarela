import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';

import 'package:tagarela/data/audio_playback.dart';
import 'package:tagarela/data/capture_device.dart';
import 'package:tagarela/data/database.dart';
import 'package:tagarela/data/media_storage.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/data/text_extractor.dart';

import 'fake_capture_api.dart';
import 'fake_extraction.dart';

class FakeMediaStorage implements MediaStorage {
  final files = <String, File>{};

  @override
  Future<String> save(String id, CaptureSource source, File file) async {
    final path = 'captures/${source.name}/$id.${file.path.split('.').last}';
    files[path] = File(path);
    return path;
  }

  @override
  Future<File?> find(String path) async => files[path];

  @override
  Future<void> delete(String path) async => files.remove(path);
}

class FakeAudioPlayback extends ChangeNotifier implements AudioPlayback {
  @override
  String? playing;

  @override
  Duration position = Duration.zero;

  @override
  Duration? total;

  final toggled = <String>[];

  @override
  Future<void> toggle(File file) async {
    toggled.add(file.path);
    playing = playing == file.path ? null : file.path;
    total = playing == null ? null : const Duration(seconds: 4);
    notifyListeners();
  }

  @override
  Future<void> stop() async {
    if (playing == null) return;
    playing = null;
    total = null;
    notifyListeners();
  }

  @override
  Future<Duration?> duration(File file) async => const Duration(seconds: 4);
}

class FakeCaptureDevice implements CaptureDevice {
  bool camera = true;
  bool microphone = true;
  File? nextPhoto = File('cache/foto.jpg');
  bool recording = false;
  int recordings = 0;
  int cancelled = 0;
  int settingsOpened = 0;
  final origins = <PhotoOrigin>[];
  final discarded = <String>[];

  @override
  Future<bool> allowCamera() async => camera;

  @override
  Future<bool> allowMicrophone() async => microphone;

  @override
  Future<void> openSettings() async => settingsOpened++;

  @override
  Future<File?> photo(PhotoOrigin origin) async {
    origins.add(origin);
    return nextPhoto;
  }

  @override
  Future<void> startRecording() async {
    recording = true;
    recordings++;
  }

  @override
  Future<File?> stopRecording() async {
    recording = false;
    return File('cache/gravacao-$recordings.m4a');
  }

  @override
  Future<void> cancelRecording() async {
    recording = false;
    cancelled++;
  }

  @override
  Future<void> discard(File file) async => discarded.add(file.path);
}

typedef FakeCaptures = ({
  CaptureStore store,
  AppDatabase db,
  FakeCaptureApi api,
  FakeMediaStorage media,
});

FakeCaptures fakeCaptures({
  String? Function()? owner,
  TextExtractor? extractor,
}) {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final api = FakeCaptureApi();
  final db = AppDatabase(NativeDatabase.memory());
  final media = FakeMediaStorage();
  final store = CaptureStore(
    CaptureService(api),
    db,
    media,
    owner: owner ?? () => 'ana@example.com',
    extractor: extractor ?? FakeTextExtractor(),
  );
  return (store: store, db: db, api: api, media: media);
}

Capture sampleCapture(
  String id, {
  CaptureSource source = CaptureSource.text,
  CaptureStatus status = CaptureStatus.ready,
  String text = 'Please mind the gap between the train and the platform.',
  List<CaptureTerm> terms = const [],
  DateTime? capturedAt,
  String? mediaPath,
  String? error,
  Set<CaptureSync> pending = const {},
}) => Capture(
  id: id,
  source: source,
  status: status,
  text: text,
  originalText: text,
  terms: terms,
  capturedAt: capturedAt ?? DateTime(2026, 10, 23, 9),
  error: error,
  mediaPath: mediaPath,
  pending: pending,
);
