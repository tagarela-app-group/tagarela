import 'dart:io';
import 'dart:math';

import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/database.dart';
import 'package:tagarela/data/media_storage.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/store.dart';

class CaptureStore extends Store<List<Capture>> {
  CaptureStore(this._service, this._db, this._media, {required this._owner});

  final CaptureService _service;
  final AppDatabase _db;
  final MediaStorage _media;
  final String? Function() _owner;

  @override
  Future<List<Capture>> fetch() async {
    final owner = _owner();
    if (owner == null) return const [];
    return [
      for (final c in await _db.capturesOf(owner))
        if (c.discardedAt == null) c,
    ];
  }

  Future<File?> mediaFile(Capture capture) async {
    final path = capture.mediaPath;
    return path == null ? null : _media.find(path);
  }

  Future<Capture> createText(String text) => _create(
    Capture(
      id: _newId(),
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
    return _create(
      Capture(
        id: id,
        source: source,
        status: CaptureStatus.waitingFile,
        capturedAt: DateTime.now(),
        mediaPath: await _media.save(id, source, file),
        pending: const {CaptureSync.create, CaptureSync.file},
      ),
    );
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
    if (owner == null) return;
    await _db.saveCapture(
      owner,
      capture.copyWith(pending: {...capture.pending, CaptureSync.file}),
    );
    await sync();
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

  Future<void> _push(String owner, Capture capture) async {
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
    await step(CaptureSync.file, () async {
      final path = current.mediaPath;
      final file = path == null ? null : await _media.find(path);
      return file == null ? null : _service.sendFile(current.id, file);
    });
    await step(CaptureSync.update, () => _service.update(current));
    await step(CaptureSync.confirm, () => _service.confirm(current.id));
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
