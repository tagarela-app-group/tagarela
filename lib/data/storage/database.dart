import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:tagarela/data/models/models.dart';

part 'database.g.dart';

class CaptureRows extends Table {
  @override
  String get tableName => 'captures';

  TextColumn get id => text()();
  TextColumn get owner => text()();
  TextColumn get course => text().nullable()();
  TextColumn get source => textEnum<CaptureSource>()();
  TextColumn get status => textEnum<CaptureStatus>()();
  TextColumn get content => text()();
  TextColumn get terms => text().map(const _TermsConverter())();
  TextColumn get error => text().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  DateTimeColumn get analyzedAt => dateTime().nullable()();
  DateTimeColumn get discardedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get mediaPath => text().nullable()();
  TextColumn get pending => text().map(const _PendingConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

class CaptureCursors extends Table {
  TextColumn get owner => text()();
  DateTimeColumn get updatedSince => dateTime()();

  @override
  Set<Column> get primaryKey => {owner};
}

@DriftDatabase(tables: [CaptureRows, CaptureCursors])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'tagarela'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await forgetServerExtraction();
      if (from < 3) {
        await m.addColumn(captureRows, captureRows.course);
        await pullEverything();
      }
      if (from < 4) await m.alterTable(TableMigration(captureRows));
    },
  );

  Future<void> pullEverything() => delete(captureCursors).go();

  Future<void> forgetServerExtraction() async {
    await customStatement(
      "UPDATE captures SET status = 'processing', error = NULL, "
      "pending = 'extract,create' "
      'WHERE discarded_at IS NULL '
      "AND (status = 'waitingFile' OR pending LIKE '%file%')",
    );
    await customStatement(
      "UPDATE captures SET status = 'processing', pending = '' "
      "WHERE status = 'waitingFile' OR pending LIKE '%file%'",
    );
  }

  Future<List<Capture>> capturesOf(String owner) async {
    final query = select(captureRows)
      ..where((c) => c.owner.equals(owner))
      ..orderBy([(c) => OrderingTerm.desc(c.capturedAt)]);
    return [for (final row in await query.get()) _toCapture(row)];
  }

  Future<Capture?> capture(String id) async {
    final query = select(captureRows)..where((c) => c.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toCapture(row);
  }

  Future<List<Capture>> capturesWithMedia() async {
    final query = select(captureRows)..where((c) => c.mediaPath.isNotNull());
    return [for (final row in await query.get()) _toCapture(row)];
  }

  Future<void> saveCapture(String owner, Capture capture) =>
      into(captureRows).insertOnConflictUpdate(
        CaptureRowsCompanion.insert(
          id: capture.id,
          owner: owner,
          course: Value(capture.course),
          source: capture.source,
          status: capture.status,
          content: capture.text,
          terms: capture.terms,
          error: Value(capture.error),
          capturedAt: capture.capturedAt,
          analyzedAt: Value(capture.analyzedAt),
          discardedAt: Value(capture.discardedAt),
          updatedAt: Value(capture.updatedAt),
          mediaPath: Value(capture.mediaPath),
          pending: capture.pending,
        ),
      );

  Future<void> clearMedia(String id) =>
      (update(captureRows)..where((c) => c.id.equals(id))).write(
        const CaptureRowsCompanion(mediaPath: Value(null)),
      );

  Future<DateTime?> cursor(String owner) async {
    final query = select(captureCursors)..where((c) => c.owner.equals(owner));
    return (await query.getSingleOrNull())?.updatedSince;
  }

  Future<void> saveCursor(String owner, DateTime updatedSince) =>
      into(captureCursors).insertOnConflictUpdate(
        CaptureCursorsCompanion.insert(
          owner: owner,
          updatedSince: updatedSince,
        ),
      );

  static Capture _toCapture(CaptureRow row) => Capture(
    id: row.id,
    course: row.course,
    source: row.source,
    status: row.status,
    text: row.content,
    terms: row.terms,
    error: row.error,
    capturedAt: row.capturedAt,
    analyzedAt: row.analyzedAt,
    discardedAt: row.discardedAt,
    updatedAt: row.updatedAt,
    mediaPath: row.mediaPath,
    pending: row.pending,
  );
}

class _TermsConverter extends TypeConverter<List<CaptureTerm>, String> {
  const _TermsConverter();

  @override
  List<CaptureTerm> fromSql(String fromDb) => [
    for (final t in jsonDecode(fromDb) as List<Object?>)
      CaptureTerm.fromJson(t! as Json),
  ];

  @override
  String toSql(List<CaptureTerm> value) =>
      jsonEncode([for (final t in value) t.toJson()]);
}

class _PendingConverter extends TypeConverter<Set<CaptureSync>, String> {
  const _PendingConverter();

  @override
  Set<CaptureSync> fromSql(String fromDb) => {
    for (final name in fromDb.split(',').where((n) => n.isNotEmpty))
      CaptureSync.values.byName(name),
  };

  @override
  String toSql(Set<CaptureSync> value) =>
      [for (final s in value) s.name].join(',');
}
