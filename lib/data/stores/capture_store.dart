import 'dart:async';
import 'dart:io';

import 'package:tagarela/data/device/text_extractor.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/storage/database.dart';
import 'package:tagarela/data/storage/media_storage.dart';
import 'package:tagarela/data/stores/store.dart';
import 'package:tagarela/data/sync/capture_synchronizer.dart';

class CaptureStore extends Store<List<Capture>> {
  CaptureStore(
    CaptureService service,
    this._db,
    this._media, {
    required this._owner,
    required this._extractor,
    String? Function()? course,
    Future<void> Function()? onConfirmed,
  }) : _course = course ?? _noCourse,
       _sync = CaptureSynchronizer(service, _db, onConfirmed: onConfirmed);

  static String? _noCourse() => null;

  final CaptureSynchronizer _sync;
  final AppDatabase _db;
  final MediaStorage _media;
  final String? Function() _owner;
  final String? Function() _course;
  final TextExtractor _extractor;

  Future<void> _extractions = Future.value();
  var _queued = 0;

  Future<void> get extractions => _extractions;

  @override
  Future<List<Capture>> fetch() async {
    final owner = _owner();
    if (owner == null) return const [];
    final course = _course();
    return [
      for (final c in await _db.capturesOf(owner))
        if (c.discardedAt == null &&
            (course == null || c.course == null || c.course == course))
          c,
    ];
  }

  Future<File?> mediaFile(Capture capture) async {
    final path = capture.mediaPath;
    return path == null ? null : _media.find(path);
  }

  Future<Capture> createText(String text) => _create(
    Capture(
      id: Capture.newId(),
      course: _course(),
      source: CaptureSource.text,
      status: CaptureStatus.ready,
      text: text,
      originalText: text,
      capturedAt: DateTime.now(),
      pending: const {CaptureSync.create},
    ),
  );

  Future<Capture> createMedia(CaptureSource source, File file) async {
    final id = Capture.newId();
    final capture = await _create(
      Capture(
        id: id,
        course: _course(),
        source: source,
        status: CaptureStatus.processing,
        capturedAt: DateTime.now(),
        mediaPath: await _media.save(id, source, file),
        pending: const {CaptureSync.extract, CaptureSync.create},
      ),
    );
    _queueExtraction(id);
    return capture;
  }

  Future<void> confirm(
    Capture capture, {
    String? text,
    List<CaptureTerm>? terms,
  }) => _change(
    capture.copyWith(
      status: CaptureStatus.analyzed,
      text: text,
      terms: terms,
      analyzedAt: DateTime.now(),
      pending: {
        ...capture.pending,
        if (text != null || terms != null) CaptureSync.update,
        CaptureSync.confirm,
      },
    ),
  );

  Future<void> discard(Capture capture) => _change(
    capture.copyWith(
      discardedAt: DateTime.now(),
      pending: capture.pending.contains(CaptureSync.create)
          ? const {}
          : {...capture.pending, CaptureSync.discard},
    ),
  );

  Future<void> processNow(Capture capture) async {
    final owner = _owner();
    if (owner == null || !capture.pending.contains(CaptureSync.extract)) {
      return;
    }
    await _db.saveCapture(
      owner,
      capture.copyWith(status: CaptureStatus.processing, error: () => null),
    );
    await load();
    _queueExtraction(capture.id);
  }

  Future<void> sync() async {
    final owner = _owner();
    if (owner == null) return;
    try {
      for (final capture in await _db.capturesOf(owner)) {
        if (capture.pending.isNotEmpty) await _sync.push(owner, capture);
      }
      await _sync.pull(owner);
    } finally {
      await load();
    }
  }

  Future<void> extractPending() async {
    final owner = _owner();
    if (owner == null) return;
    for (final capture in (await _db.capturesOf(owner)).reversed) {
      if (capture.waitsExtraction) _queueExtraction(capture.id);
    }
  }

  Future<void> cleanMedia([DateTime? now]) async {
    final at = now ?? DateTime.now();
    for (final capture in await _db.capturesWithMedia()) {
      if (!capture.mediaExpired(at)) continue;
      try {
        await _media.delete(capture.mediaPath!);
      } on FileSystemException {
        continue;
      }
      await _db.clearMedia(capture.id);
    }
  }

  Future<Capture> _create(Capture capture) async {
    await _change(capture);
    return await _db.capture(capture.id) ?? capture;
  }

  Future<void> _change(Capture capture) async {
    final owner = _owner();
    if (owner == null) return;
    await _db.saveCapture(owner, capture);
    try {
      await _sync.push(owner, capture);
    } on Exception {
      return;
    } finally {
      await load();
    }
  }

  void _queueExtraction(String id) {
    _queued++;
    _extractions = _extractions
        .then((_) async {
          try {
            await _extract(id);
          } finally {
            if (--_queued == 0) await _extractor.release();
          }
        })
        .onError((_, _) {});
  }

  Future<void> _extract(String id) async {
    final owner = _owner();
    final capture = await _ownCapture(owner, id);
    final path = capture?.mediaPath;
    if (owner == null || capture == null || !capture.waitsExtraction) return;
    final file = path == null ? null : await _media.find(path);
    Capture done;
    try {
      if (file == null) {
        throw const ExtractionException(ExtractionError.failed);
      }
      final text = await _extractor.extract(capture.source, file);
      done = capture.copyWith(
        status: CaptureStatus.ready,
        text: text,
        originalText: text,
        error: () => null,
        processedAt: DateTime.now(),
        pending: capture.pending.difference({CaptureSync.extract}),
      );
    } on ExtractionException catch (e) {
      if (e.error == ExtractionError.modelMissing) return;
      done = capture.copyWith(
        status: CaptureStatus.failed,
        error: () => e.error.code,
      );
    }
    final latest = await _ownCapture(owner, id);
    if (latest == null || !latest.waitsExtraction) return;
    await _db.saveCapture(owner, done);
    try {
      if (done.status == CaptureStatus.ready) await _sync.push(owner, done);
    } on Exception {
      return;
    } finally {
      await load();
    }
  }

  Future<Capture?> _ownCapture(String? owner, String id) async {
    if (owner == null) return null;
    for (final capture in await _db.capturesOf(owner)) {
      if (capture.id == id) return capture;
    }
    return null;
  }
}
