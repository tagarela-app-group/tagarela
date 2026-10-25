import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/database.dart';
import 'package:tagarela/data/media_storage.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/store.dart';
import 'package:tagarela/data/text_extractor.dart';

class CaptureStore extends Store<List<Capture>> {
  CaptureStore(
    this._service,
    this._db,
    this._media, {
    required this._owner,
    required this._extractor,
    String? Function()? course,
    this._onConfirmed,
  }) : _course = course ?? _noCourse;

  static String? _noCourse() => null;

  final CaptureService _service;
  final AppDatabase _db;
  final MediaStorage _media;
  final String? Function() _owner;
  final String? Function() _course;
  final TextExtractor _extractor;
  final Future<void> Function()? _onConfirmed;

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
      id: _newId(),
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
    final id = _newId();
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
        if (capture.pending.isNotEmpty) await _push(owner, capture);
      }
      await _pull(owner);
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
      await _push(owner, capture);
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
      if (done.status == CaptureStatus.ready) await _push(owner, done);
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

  Future<void> _push(String owner, Capture capture) async {
    if (capture.pending.contains(CaptureSync.extract)) return;
    var current = capture;

    Future<void> step(CaptureSync op, Future<Capture?> Function() call) async {
      if (!current.pending.contains(op)) return;
      Capture? server;
      try {
        server = await call();
      } on ApiException catch (e) {
        if (!e.rejected) rethrow;
      }
      current = (server == null ? current : current.merge(server)).copyWith(
        pending: current.pending.difference({op}),
      );
      await _db.saveCapture(owner, current);
    }

    if (current.pending.contains(CaptureSync.discard)) {
      return step(CaptureSync.discard, () async {
        await _service.discard(current.id);
        return null;
      });
    }
    await step(CaptureSync.create, () => _service.create(current));
    await step(CaptureSync.update, () => _service.update(current));
    if (!current.pending.contains(CaptureSync.confirm)) return;
    await step(CaptureSync.confirm, () => _service.confirm(current.id));
    if (_onConfirmed case final reload?) unawaited(reload());
  }

  Future<void> _pull(String owner) async {
    final since = await _db.cursor(owner);
    final changes = await _service.changes(since);
    var latest = since;
    for (final server in changes) {
      final local = await _db.capture(server.id);
      await _db.saveCapture(owner, local?.merge(server) ?? server);
      final updatedAt = server.updatedAt;
      if (updatedAt != null && (latest == null || updatedAt.isAfter(latest))) {
        latest = updatedAt;
      }
    }
    if (latest != null && latest != since) await _db.saveCursor(owner, latest);
  }

  static String _newId() {
    final random = Random.secure();
    final bytes = [for (var i = 0; i < 16; i++) random.nextInt(256)];
    bytes[6] = bytes[6] & 0x0f | 0x40;
    bytes[8] = bytes[8] & 0x3f | 0x80;
    final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')];
    return [
      hex.sublist(0, 4),
      hex.sublist(4, 6),
      hex.sublist(6, 8),
      hex.sublist(8, 10),
      hex.sublist(10),
    ].map((part) => part.join()).join('-');
  }
}
