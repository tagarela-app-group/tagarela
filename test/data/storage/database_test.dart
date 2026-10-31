import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/storage/database.dart';

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
    'terms, error, captured_at, discarded_at, pending) '
    "VALUES (?, 'ana', 'photo', ?, '', '[]', ?, '2026-10-23T10:00:00.000', ?, ?)",
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

  test('pullEverything esquece o cursor pra trazer o curso de tudo', () async {
    await db.saveCursor('ana', DateTime.utc(2026, 10, 23));

    await db.pullEverything();

    expect(await db.cursor('ana'), isNull);
  });

  test('banco da versão 3 mantém as capturas ao tirar as colunas', () async {
    final old = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(
            'CREATE TABLE captures (id TEXT NOT NULL PRIMARY KEY, '
            'owner TEXT NOT NULL, course TEXT, source TEXT NOT NULL, '
            'status TEXT NOT NULL, content TEXT NOT NULL, '
            'original_content TEXT NOT NULL, terms TEXT NOT NULL, error TEXT, '
            'captured_at TEXT NOT NULL, processed_at TEXT, analyzed_at TEXT, '
            'discarded_at TEXT, updated_at TEXT, media_path TEXT, '
            'pending TEXT NOT NULL)',
          );
          raw.execute(
            'CREATE TABLE capture_cursors (owner TEXT NOT NULL PRIMARY KEY, '
            'updated_since TEXT NOT NULL)',
          );
          raw.execute(
            'INSERT INTO captures (id, owner, source, status, content, '
            'original_content, terms, captured_at, processed_at, pending) '
            "VALUES ('c1', 'ana', 'text', 'ready', 'mind the gap', 'MIND', "
            "'[]', '2026-10-23T10:00:00.000', '2026-10-23T10:00:05.000', "
            "'update')",
          );
          raw.userVersion = 3;
        },
      ),
    );
    addTearDown(old.close);

    final capture = (await old.capture('c1'))!;

    expect(capture.text, 'mind the gap');
    expect(capture.pending, {CaptureSync.update});
    await old.saveCapture('ana', capture.copyWith(text: 'mind'));
    expect((await old.capture('c1'))!.text, 'mind');
  });
}
