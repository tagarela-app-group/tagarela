import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';

import 'package:tagarela/data/audio_playback.dart';
import 'package:tagarela/data/database.dart';
import 'package:tagarela/data/media_storage.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/stores/capture_store.dart';

import 'fake_capture_api.dart';

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
  Future<Duration?> duration(File file) async => const Duration(seconds: 4);
}

typedef FakeCaptures = ({
  CaptureStore store,
  AppDatabase db,
  FakeCaptureApi api,
  FakeMediaStorage media,
});

FakeCaptures fakeCaptures({String? Function()? owner}) {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final api = FakeCaptureApi();
  final db = AppDatabase(NativeDatabase.memory());
  final media = FakeMediaStorage();
  final store = CaptureStore(
    CaptureService(api),
    db,
    media,
    owner: owner ?? () => 'ana@example.com',
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
  Set<CaptureSync> pending = const {},
}) => Capture(
  id: id,
  source: source,
  status: status,
  text: text,
  originalText: text,
  terms: terms,
  capturedAt: capturedAt ?? DateTime(2026, 10, 23, 9),
  mediaPath: mediaPath,
  pending: pending,
);
