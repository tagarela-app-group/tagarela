import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/database.dart';
import 'package:tagarela/data/models.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> insert(
    String id, {
    required String status,
    required String pending,
    String? error,
    String? discardedAt,
  }) => db.customStatement(
    'INSERT INTO captures (id, owner, source, status, content, '
    'original_content, terms, error, captured_at, discarded_at, pending) '
    "VALUES (?, 'ana', 'photo', ?, '', '', '[]', ?, '2026-10-23T10:00:00.000', ?, ?)",
    [id, status, error, discardedAt, pending],
  );

  test('captura do modo servidor volta pra extração no celular', () async {
    await insert('esperando', status: 'waitingFile', pending: 'create,file');
    await insert(
      'falhou',
      status: 'failed',
      pending: 'file',
      error: 'processing_failed',
    );
    await insert(
      'descartada',
      status: 'waitingFile',
      pending: 'file',
      discardedAt: '2026-10-23T11:00:00.000',
    );
    await insert('pronta', status: 'ready', pending: 'update');

    await db.forgetServerExtraction();

    final captures = {for (final c in await db.capturesOf('ana')) c.id: c};
    for (final id in ['esperando', 'falhou']) {
      expect(captures[id]!.status, CaptureStatus.processing, reason: id);
      expect(captures[id]!.error, isNull, reason: id);
      expect(captures[id]!.pending, {
        CaptureSync.extract,
        CaptureSync.create,
      }, reason: id);
      expect(captures[id]!.waitsExtraction, isTrue, reason: id);
    }
    expect(captures['descartada']!.pending, isEmpty);
    expect(captures['descartada']!.waitsExtraction, isFalse);
    expect(captures['pronta']!.status, CaptureStatus.ready);
    expect(captures['pronta']!.pending, {CaptureSync.update});
  });
}
