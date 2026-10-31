import 'dart:async';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/storage/database.dart';

class CaptureSynchronizer {
  CaptureSynchronizer(this._service, this._db, {this._onConfirmed});

  final CaptureService _service;
  final AppDatabase _db;
  final Future<void> Function()? _onConfirmed;

  Future<void> push(String owner, Capture capture) async {
    if (capture.pending.contains(CaptureSync.extract)) return;
    var current = capture;

    Future<void> step(CaptureSync op, Future<Capture?> Function() call) async {
      if (!current.pending.contains(op)) return;
      if (current.refused && op != CaptureSync.discard) return;
      Capture? server;
      try {
        server = await call();
      } on ApiException catch (e) {
        if (!e.rejected) rethrow;
        if (!e.settled) {
          current = current.copyWith(
            status: CaptureStatus.failed,
            error: () => Capture.refusedError,
            analyzedAt: () => null,
          );
          return _db.saveCapture(owner, current);
        }
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
    if (current.refused) return;
    if (_onConfirmed case final reload?) unawaited(reload());
  }

  Future<void> pull(String owner) async {
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
}
