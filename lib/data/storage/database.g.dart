// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CaptureRowsTable extends CaptureRows
    with TableInfo<$CaptureRowsTable, CaptureRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaptureRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseMeta = const VerificationMeta('course');
  @override
  late final GeneratedColumn<String> course = GeneratedColumn<String>(
    'course',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CaptureSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CaptureSource>($CaptureRowsTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<CaptureStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CaptureStatus>($CaptureRowsTable.$converterstatus);
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<CaptureTerm>, String> terms =
      GeneratedColumn<String>(
        'terms',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<CaptureTerm>>($CaptureRowsTable.$converterterms);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analyzedAtMeta = const VerificationMeta(
    'analyzedAt',
  );
  @override
  late final GeneratedColumn<DateTime> analyzedAt = GeneratedColumn<DateTime>(
    'analyzed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discardedAtMeta = const VerificationMeta(
    'discardedAt',
  );
  @override
  late final GeneratedColumn<DateTime> discardedAt = GeneratedColumn<DateTime>(
    'discarded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaPathMeta = const VerificationMeta(
    'mediaPath',
  );
  @override
  late final GeneratedColumn<String> mediaPath = GeneratedColumn<String>(
    'media_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Set<CaptureSync>, String>
  pending = GeneratedColumn<String>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Set<CaptureSync>>($CaptureRowsTable.$converterpending);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    owner,
    course,
    source,
    status,
    content,
    terms,
    error,
    capturedAt,
    analyzedAt,
    discardedAt,
    updatedAt,
    mediaPath,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'captures';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaptureRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('course')) {
      context.handle(
        _courseMeta,
        course.isAcceptableOrUnknown(data['course']!, _courseMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
        _analyzedAtMeta,
        analyzedAt.isAcceptableOrUnknown(data['analyzed_at']!, _analyzedAtMeta),
      );
    }
    if (data.containsKey('discarded_at')) {
      context.handle(
        _discardedAtMeta,
        discardedAt.isAcceptableOrUnknown(
          data['discarded_at']!,
          _discardedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('media_path')) {
      context.handle(
        _mediaPathMeta,
        mediaPath.isAcceptableOrUnknown(data['media_path']!, _mediaPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaptureRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaptureRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      course: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course'],
      ),
      source: $CaptureRowsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      status: $CaptureRowsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      terms: $CaptureRowsTable.$converterterms.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}terms'],
        )!,
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      analyzedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}analyzed_at'],
      ),
      discardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}discarded_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      mediaPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_path'],
      ),
      pending: $CaptureRowsTable.$converterpending.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pending'],
        )!,
      ),
    );
  }

  @override
  $CaptureRowsTable createAlias(String alias) {
    return $CaptureRowsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CaptureSource, String, String> $convertersource =
      const EnumNameConverter<CaptureSource>(CaptureSource.values);
  static JsonTypeConverter2<CaptureStatus, String, String> $converterstatus =
      const EnumNameConverter<CaptureStatus>(CaptureStatus.values);
  static TypeConverter<List<CaptureTerm>, String> $converterterms =
      const _TermsConverter();
  static TypeConverter<Set<CaptureSync>, String> $converterpending =
      const _PendingConverter();
}

class CaptureRow extends DataClass implements Insertable<CaptureRow> {
  final String id;
  final String owner;
  final String? course;
  final CaptureSource source;
  final CaptureStatus status;
  final String content;
  final List<CaptureTerm> terms;
  final String? error;
  final DateTime capturedAt;
  final DateTime? analyzedAt;
  final DateTime? discardedAt;
  final DateTime? updatedAt;
  final String? mediaPath;
  final Set<CaptureSync> pending;
  const CaptureRow({
    required this.id,
    required this.owner,
    this.course,
    required this.source,
    required this.status,
    required this.content,
    required this.terms,
    this.error,
    required this.capturedAt,
    this.analyzedAt,
    this.discardedAt,
    this.updatedAt,
    this.mediaPath,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner'] = Variable<String>(owner);
    if (!nullToAbsent || course != null) {
      map['course'] = Variable<String>(course);
    }
    {
      map['source'] = Variable<String>(
        $CaptureRowsTable.$convertersource.toSql(source),
      );
    }
    {
      map['status'] = Variable<String>(
        $CaptureRowsTable.$converterstatus.toSql(status),
      );
    }
    map['content'] = Variable<String>(content);
    {
      map['terms'] = Variable<String>(
        $CaptureRowsTable.$converterterms.toSql(terms),
      );
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || analyzedAt != null) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt);
    }
    if (!nullToAbsent || discardedAt != null) {
      map['discarded_at'] = Variable<DateTime>(discardedAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || mediaPath != null) {
      map['media_path'] = Variable<String>(mediaPath);
    }
    {
      map['pending'] = Variable<String>(
        $CaptureRowsTable.$converterpending.toSql(pending),
      );
    }
    return map;
  }

  CaptureRowsCompanion toCompanion(bool nullToAbsent) {
    return CaptureRowsCompanion(
      id: Value(id),
      owner: Value(owner),
      course: course == null && nullToAbsent
          ? const Value.absent()
          : Value(course),
      source: Value(source),
      status: Value(status),
      content: Value(content),
      terms: Value(terms),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      capturedAt: Value(capturedAt),
      analyzedAt: analyzedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(analyzedAt),
      discardedAt: discardedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(discardedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      mediaPath: mediaPath == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaPath),
      pending: Value(pending),
    );
  }

  factory CaptureRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureRow(
      id: serializer.fromJson<String>(json['id']),
      owner: serializer.fromJson<String>(json['owner']),
      course: serializer.fromJson<String?>(json['course']),
      source: $CaptureRowsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      status: $CaptureRowsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      content: serializer.fromJson<String>(json['content']),
      terms: serializer.fromJson<List<CaptureTerm>>(json['terms']),
      error: serializer.fromJson<String?>(json['error']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      analyzedAt: serializer.fromJson<DateTime?>(json['analyzedAt']),
      discardedAt: serializer.fromJson<DateTime?>(json['discardedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      mediaPath: serializer.fromJson<String?>(json['mediaPath']),
      pending: serializer.fromJson<Set<CaptureSync>>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'owner': serializer.toJson<String>(owner),
      'course': serializer.toJson<String?>(course),
      'source': serializer.toJson<String>(
        $CaptureRowsTable.$convertersource.toJson(source),
      ),
      'status': serializer.toJson<String>(
        $CaptureRowsTable.$converterstatus.toJson(status),
      ),
      'content': serializer.toJson<String>(content),
      'terms': serializer.toJson<List<CaptureTerm>>(terms),
      'error': serializer.toJson<String?>(error),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'analyzedAt': serializer.toJson<DateTime?>(analyzedAt),
      'discardedAt': serializer.toJson<DateTime?>(discardedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'mediaPath': serializer.toJson<String?>(mediaPath),
      'pending': serializer.toJson<Set<CaptureSync>>(pending),
    };
  }

  CaptureRow copyWith({
    String? id,
    String? owner,
    Value<String?> course = const Value.absent(),
    CaptureSource? source,
    CaptureStatus? status,
    String? content,
    List<CaptureTerm>? terms,
    Value<String?> error = const Value.absent(),
    DateTime? capturedAt,
    Value<DateTime?> analyzedAt = const Value.absent(),
    Value<DateTime?> discardedAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> mediaPath = const Value.absent(),
    Set<CaptureSync>? pending,
  }) => CaptureRow(
    id: id ?? this.id,
    owner: owner ?? this.owner,
    course: course.present ? course.value : this.course,
    source: source ?? this.source,
    status: status ?? this.status,
    content: content ?? this.content,
    terms: terms ?? this.terms,
    error: error.present ? error.value : this.error,
    capturedAt: capturedAt ?? this.capturedAt,
    analyzedAt: analyzedAt.present ? analyzedAt.value : this.analyzedAt,
    discardedAt: discardedAt.present ? discardedAt.value : this.discardedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    mediaPath: mediaPath.present ? mediaPath.value : this.mediaPath,
    pending: pending ?? this.pending,
  );
  CaptureRow copyWithCompanion(CaptureRowsCompanion data) {
    return CaptureRow(
      id: data.id.present ? data.id.value : this.id,
      owner: data.owner.present ? data.owner.value : this.owner,
      course: data.course.present ? data.course.value : this.course,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      content: data.content.present ? data.content.value : this.content,
      terms: data.terms.present ? data.terms.value : this.terms,
      error: data.error.present ? data.error.value : this.error,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      analyzedAt: data.analyzedAt.present
          ? data.analyzedAt.value
          : this.analyzedAt,
      discardedAt: data.discardedAt.present
          ? data.discardedAt.value
          : this.discardedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      mediaPath: data.mediaPath.present ? data.mediaPath.value : this.mediaPath,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureRow(')
          ..write('id: $id, ')
          ..write('owner: $owner, ')
          ..write('course: $course, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('content: $content, ')
          ..write('terms: $terms, ')
          ..write('error: $error, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('discardedAt: $discardedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    owner,
    course,
    source,
    status,
    content,
    terms,
    error,
    capturedAt,
    analyzedAt,
    discardedAt,
    updatedAt,
    mediaPath,
    pending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureRow &&
          other.id == this.id &&
          other.owner == this.owner &&
          other.course == this.course &&
          other.source == this.source &&
          other.status == this.status &&
          other.content == this.content &&
          other.terms == this.terms &&
          other.error == this.error &&
          other.capturedAt == this.capturedAt &&
          other.analyzedAt == this.analyzedAt &&
          other.discardedAt == this.discardedAt &&
          other.updatedAt == this.updatedAt &&
          other.mediaPath == this.mediaPath &&
          other.pending == this.pending);
}

class CaptureRowsCompanion extends UpdateCompanion<CaptureRow> {
  final Value<String> id;
  final Value<String> owner;
  final Value<String?> course;
  final Value<CaptureSource> source;
  final Value<CaptureStatus> status;
  final Value<String> content;
  final Value<List<CaptureTerm>> terms;
  final Value<String?> error;
  final Value<DateTime> capturedAt;
  final Value<DateTime?> analyzedAt;
  final Value<DateTime?> discardedAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> mediaPath;
  final Value<Set<CaptureSync>> pending;
  final Value<int> rowid;
  const CaptureRowsCompanion({
    this.id = const Value.absent(),
    this.owner = const Value.absent(),
    this.course = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.content = const Value.absent(),
    this.terms = const Value.absent(),
    this.error = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.analyzedAt = const Value.absent(),
    this.discardedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.mediaPath = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaptureRowsCompanion.insert({
    required String id,
    required String owner,
    this.course = const Value.absent(),
    required CaptureSource source,
    required CaptureStatus status,
    required String content,
    required List<CaptureTerm> terms,
    this.error = const Value.absent(),
    required DateTime capturedAt,
    this.analyzedAt = const Value.absent(),
    this.discardedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.mediaPath = const Value.absent(),
    required Set<CaptureSync> pending,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       owner = Value(owner),
       source = Value(source),
       status = Value(status),
       content = Value(content),
       terms = Value(terms),
       capturedAt = Value(capturedAt),
       pending = Value(pending);
  static Insertable<CaptureRow> custom({
    Expression<String>? id,
    Expression<String>? owner,
    Expression<String>? course,
    Expression<String>? source,
    Expression<String>? status,
    Expression<String>? content,
    Expression<String>? terms,
    Expression<String>? error,
    Expression<DateTime>? capturedAt,
    Expression<DateTime>? analyzedAt,
    Expression<DateTime>? discardedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? mediaPath,
    Expression<String>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (owner != null) 'owner': owner,
      if (course != null) 'course': course,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (content != null) 'content': content,
      if (terms != null) 'terms': terms,
      if (error != null) 'error': error,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
      if (discardedAt != null) 'discarded_at': discardedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (mediaPath != null) 'media_path': mediaPath,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaptureRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? owner,
    Value<String?>? course,
    Value<CaptureSource>? source,
    Value<CaptureStatus>? status,
    Value<String>? content,
    Value<List<CaptureTerm>>? terms,
    Value<String?>? error,
    Value<DateTime>? capturedAt,
    Value<DateTime?>? analyzedAt,
    Value<DateTime?>? discardedAt,
    Value<DateTime?>? updatedAt,
    Value<String?>? mediaPath,
    Value<Set<CaptureSync>>? pending,
    Value<int>? rowid,
  }) {
    return CaptureRowsCompanion(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      course: course ?? this.course,
      source: source ?? this.source,
      status: status ?? this.status,
      content: content ?? this.content,
      terms: terms ?? this.terms,
      error: error ?? this.error,
      capturedAt: capturedAt ?? this.capturedAt,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      discardedAt: discardedAt ?? this.discardedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaPath: mediaPath ?? this.mediaPath,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (course.present) {
      map['course'] = Variable<String>(course.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $CaptureRowsTable.$convertersource.toSql(source.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CaptureRowsTable.$converterstatus.toSql(status.value),
      );
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (terms.present) {
      map['terms'] = Variable<String>(
        $CaptureRowsTable.$converterterms.toSql(terms.value),
      );
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt.value);
    }
    if (discardedAt.present) {
      map['discarded_at'] = Variable<DateTime>(discardedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (mediaPath.present) {
      map['media_path'] = Variable<String>(mediaPath.value);
    }
    if (pending.present) {
      map['pending'] = Variable<String>(
        $CaptureRowsTable.$converterpending.toSql(pending.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureRowsCompanion(')
          ..write('id: $id, ')
          ..write('owner: $owner, ')
          ..write('course: $course, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('content: $content, ')
          ..write('terms: $terms, ')
          ..write('error: $error, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('discardedAt: $discardedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaptureCursorsTable extends CaptureCursors
    with TableInfo<$CaptureCursorsTable, CaptureCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaptureCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedSinceMeta = const VerificationMeta(
    'updatedSince',
  );
  @override
  late final GeneratedColumn<DateTime> updatedSince = GeneratedColumn<DateTime>(
    'updated_since',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [owner, updatedSince];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capture_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaptureCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('updated_since')) {
      context.handle(
        _updatedSinceMeta,
        updatedSince.isAcceptableOrUnknown(
          data['updated_since']!,
          _updatedSinceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedSinceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {owner};
  @override
  CaptureCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaptureCursor(
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      updatedSince: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_since'],
      )!,
    );
  }

  @override
  $CaptureCursorsTable createAlias(String alias) {
    return $CaptureCursorsTable(attachedDatabase, alias);
  }
}

class CaptureCursor extends DataClass implements Insertable<CaptureCursor> {
  final String owner;
  final DateTime updatedSince;
  const CaptureCursor({required this.owner, required this.updatedSince});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner'] = Variable<String>(owner);
    map['updated_since'] = Variable<DateTime>(updatedSince);
    return map;
  }

  CaptureCursorsCompanion toCompanion(bool nullToAbsent) {
    return CaptureCursorsCompanion(
      owner: Value(owner),
      updatedSince: Value(updatedSince),
    );
  }

  factory CaptureCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureCursor(
      owner: serializer.fromJson<String>(json['owner']),
      updatedSince: serializer.fromJson<DateTime>(json['updatedSince']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'owner': serializer.toJson<String>(owner),
      'updatedSince': serializer.toJson<DateTime>(updatedSince),
    };
  }

  CaptureCursor copyWith({String? owner, DateTime? updatedSince}) =>
      CaptureCursor(
        owner: owner ?? this.owner,
        updatedSince: updatedSince ?? this.updatedSince,
      );
  CaptureCursor copyWithCompanion(CaptureCursorsCompanion data) {
    return CaptureCursor(
      owner: data.owner.present ? data.owner.value : this.owner,
      updatedSince: data.updatedSince.present
          ? data.updatedSince.value
          : this.updatedSince,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureCursor(')
          ..write('owner: $owner, ')
          ..write('updatedSince: $updatedSince')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(owner, updatedSince);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureCursor &&
          other.owner == this.owner &&
          other.updatedSince == this.updatedSince);
}

class CaptureCursorsCompanion extends UpdateCompanion<CaptureCursor> {
  final Value<String> owner;
  final Value<DateTime> updatedSince;
  final Value<int> rowid;
  const CaptureCursorsCompanion({
    this.owner = const Value.absent(),
    this.updatedSince = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaptureCursorsCompanion.insert({
    required String owner,
    required DateTime updatedSince,
    this.rowid = const Value.absent(),
  }) : owner = Value(owner),
       updatedSince = Value(updatedSince);
  static Insertable<CaptureCursor> custom({
    Expression<String>? owner,
    Expression<DateTime>? updatedSince,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (owner != null) 'owner': owner,
      if (updatedSince != null) 'updated_since': updatedSince,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaptureCursorsCompanion copyWith({
    Value<String>? owner,
    Value<DateTime>? updatedSince,
    Value<int>? rowid,
  }) {
    return CaptureCursorsCompanion(
      owner: owner ?? this.owner,
      updatedSince: updatedSince ?? this.updatedSince,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (updatedSince.present) {
      map['updated_since'] = Variable<DateTime>(updatedSince.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureCursorsCompanion(')
          ..write('owner: $owner, ')
          ..write('updatedSince: $updatedSince, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewAttemptRowsTable extends ReviewAttemptRows
    with TableInfo<$ReviewAttemptRowsTable, ReviewAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewAttemptRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExerciseKind>($ReviewAttemptRowsTable.$converterkind);
  static const VerificationMeta _exerciseMeta = const VerificationMeta(
    'exercise',
  );
  @override
  late final GeneratedColumn<String> exercise = GeneratedColumn<String>(
    'exercise',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Outcome, String> outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Outcome>($ReviewAttemptRowsTable.$converteroutcome);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    owner,
    term,
    kind,
    exercise,
    outcome,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewAttemptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('exercise')) {
      context.handle(
        _exerciseMeta,
        exercise.isAcceptableOrUnknown(data['exercise']!, _exerciseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewAttemptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      kind: $ReviewAttemptRowsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      exercise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise'],
      ),
      outcome: $ReviewAttemptRowsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        )!,
      ),
    );
  }

  @override
  $ReviewAttemptRowsTable createAlias(String alias) {
    return $ReviewAttemptRowsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExerciseKind, String, String> $converterkind =
      const EnumNameConverter<ExerciseKind>(ExerciseKind.values);
  static JsonTypeConverter2<Outcome, String, String> $converteroutcome =
      const EnumNameConverter<Outcome>(Outcome.values);
}

class ReviewAttemptRow extends DataClass
    implements Insertable<ReviewAttemptRow> {
  final String id;
  final String owner;
  final String term;
  final ExerciseKind kind;
  final String? exercise;
  final Outcome outcome;
  const ReviewAttemptRow({
    required this.id,
    required this.owner,
    required this.term,
    required this.kind,
    this.exercise,
    required this.outcome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner'] = Variable<String>(owner);
    map['term'] = Variable<String>(term);
    {
      map['kind'] = Variable<String>(
        $ReviewAttemptRowsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || exercise != null) {
      map['exercise'] = Variable<String>(exercise);
    }
    {
      map['outcome'] = Variable<String>(
        $ReviewAttemptRowsTable.$converteroutcome.toSql(outcome),
      );
    }
    return map;
  }

  ReviewAttemptRowsCompanion toCompanion(bool nullToAbsent) {
    return ReviewAttemptRowsCompanion(
      id: Value(id),
      owner: Value(owner),
      term: Value(term),
      kind: Value(kind),
      exercise: exercise == null && nullToAbsent
          ? const Value.absent()
          : Value(exercise),
      outcome: Value(outcome),
    );
  }

  factory ReviewAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewAttemptRow(
      id: serializer.fromJson<String>(json['id']),
      owner: serializer.fromJson<String>(json['owner']),
      term: serializer.fromJson<String>(json['term']),
      kind: $ReviewAttemptRowsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      exercise: serializer.fromJson<String?>(json['exercise']),
      outcome: $ReviewAttemptRowsTable.$converteroutcome.fromJson(
        serializer.fromJson<String>(json['outcome']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'owner': serializer.toJson<String>(owner),
      'term': serializer.toJson<String>(term),
      'kind': serializer.toJson<String>(
        $ReviewAttemptRowsTable.$converterkind.toJson(kind),
      ),
      'exercise': serializer.toJson<String?>(exercise),
      'outcome': serializer.toJson<String>(
        $ReviewAttemptRowsTable.$converteroutcome.toJson(outcome),
      ),
    };
  }

  ReviewAttemptRow copyWith({
    String? id,
    String? owner,
    String? term,
    ExerciseKind? kind,
    Value<String?> exercise = const Value.absent(),
    Outcome? outcome,
  }) => ReviewAttemptRow(
    id: id ?? this.id,
    owner: owner ?? this.owner,
    term: term ?? this.term,
    kind: kind ?? this.kind,
    exercise: exercise.present ? exercise.value : this.exercise,
    outcome: outcome ?? this.outcome,
  );
  ReviewAttemptRow copyWithCompanion(ReviewAttemptRowsCompanion data) {
    return ReviewAttemptRow(
      id: data.id.present ? data.id.value : this.id,
      owner: data.owner.present ? data.owner.value : this.owner,
      term: data.term.present ? data.term.value : this.term,
      kind: data.kind.present ? data.kind.value : this.kind,
      exercise: data.exercise.present ? data.exercise.value : this.exercise,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewAttemptRow(')
          ..write('id: $id, ')
          ..write('owner: $owner, ')
          ..write('term: $term, ')
          ..write('kind: $kind, ')
          ..write('exercise: $exercise, ')
          ..write('outcome: $outcome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, owner, term, kind, exercise, outcome);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewAttemptRow &&
          other.id == this.id &&
          other.owner == this.owner &&
          other.term == this.term &&
          other.kind == this.kind &&
          other.exercise == this.exercise &&
          other.outcome == this.outcome);
}

class ReviewAttemptRowsCompanion extends UpdateCompanion<ReviewAttemptRow> {
  final Value<String> id;
  final Value<String> owner;
  final Value<String> term;
  final Value<ExerciseKind> kind;
  final Value<String?> exercise;
  final Value<Outcome> outcome;
  final Value<int> rowid;
  const ReviewAttemptRowsCompanion({
    this.id = const Value.absent(),
    this.owner = const Value.absent(),
    this.term = const Value.absent(),
    this.kind = const Value.absent(),
    this.exercise = const Value.absent(),
    this.outcome = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewAttemptRowsCompanion.insert({
    required String id,
    required String owner,
    required String term,
    required ExerciseKind kind,
    this.exercise = const Value.absent(),
    required Outcome outcome,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       owner = Value(owner),
       term = Value(term),
       kind = Value(kind),
       outcome = Value(outcome);
  static Insertable<ReviewAttemptRow> custom({
    Expression<String>? id,
    Expression<String>? owner,
    Expression<String>? term,
    Expression<String>? kind,
    Expression<String>? exercise,
    Expression<String>? outcome,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (owner != null) 'owner': owner,
      if (term != null) 'term': term,
      if (kind != null) 'kind': kind,
      if (exercise != null) 'exercise': exercise,
      if (outcome != null) 'outcome': outcome,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewAttemptRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? owner,
    Value<String>? term,
    Value<ExerciseKind>? kind,
    Value<String?>? exercise,
    Value<Outcome>? outcome,
    Value<int>? rowid,
  }) {
    return ReviewAttemptRowsCompanion(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      term: term ?? this.term,
      kind: kind ?? this.kind,
      exercise: exercise ?? this.exercise,
      outcome: outcome ?? this.outcome,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ReviewAttemptRowsTable.$converterkind.toSql(kind.value),
      );
    }
    if (exercise.present) {
      map['exercise'] = Variable<String>(exercise.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $ReviewAttemptRowsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewAttemptRowsCompanion(')
          ..write('id: $id, ')
          ..write('owner: $owner, ')
          ..write('term: $term, ')
          ..write('kind: $kind, ')
          ..write('exercise: $exercise, ')
          ..write('outcome: $outcome, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CaptureRowsTable captureRows = $CaptureRowsTable(this);
  late final $CaptureCursorsTable captureCursors = $CaptureCursorsTable(this);
  late final $ReviewAttemptRowsTable reviewAttemptRows =
      $ReviewAttemptRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    captureRows,
    captureCursors,
    reviewAttemptRows,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CaptureRowsTableCreateCompanionBuilder =
    CaptureRowsCompanion Function({
      required String id,
      required String owner,
      Value<String?> course,
      required CaptureSource source,
      required CaptureStatus status,
      required String content,
      required List<CaptureTerm> terms,
      Value<String?> error,
      required DateTime capturedAt,
      Value<DateTime?> analyzedAt,
      Value<DateTime?> discardedAt,
      Value<DateTime?> updatedAt,
      Value<String?> mediaPath,
      required Set<CaptureSync> pending,
      Value<int> rowid,
    });
typedef $$CaptureRowsTableUpdateCompanionBuilder =
    CaptureRowsCompanion Function({
      Value<String> id,
      Value<String> owner,
      Value<String?> course,
      Value<CaptureSource> source,
      Value<CaptureStatus> status,
      Value<String> content,
      Value<List<CaptureTerm>> terms,
      Value<String?> error,
      Value<DateTime> capturedAt,
      Value<DateTime?> analyzedAt,
      Value<DateTime?> discardedAt,
      Value<DateTime?> updatedAt,
      Value<String?> mediaPath,
      Value<Set<CaptureSync>> pending,
      Value<int> rowid,
    });

class $$CaptureRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CaptureRowsTable> {
  $$CaptureRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get course => $composableBuilder(
    column: $table.course,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CaptureSource, CaptureSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CaptureStatus, CaptureStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<CaptureTerm>, List<CaptureTerm>, String>
  get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get discardedAt => $composableBuilder(
    column: $table.discardedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaPath => $composableBuilder(
    column: $table.mediaPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<CaptureSync>, Set<CaptureSync>, String>
  get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$CaptureRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaptureRowsTable> {
  $$CaptureRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get course => $composableBuilder(
    column: $table.course,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get discardedAt => $composableBuilder(
    column: $table.discardedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaPath => $composableBuilder(
    column: $table.mediaPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CaptureRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaptureRowsTable> {
  $$CaptureRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get course =>
      $composableBuilder(column: $table.course, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CaptureSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CaptureStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<CaptureTerm>, String> get terms =>
      $composableBuilder(column: $table.terms, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get discardedAt => $composableBuilder(
    column: $table.discardedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get mediaPath =>
      $composableBuilder(column: $table.mediaPath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<CaptureSync>, String> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$CaptureRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaptureRowsTable,
          CaptureRow,
          $$CaptureRowsTableFilterComposer,
          $$CaptureRowsTableOrderingComposer,
          $$CaptureRowsTableAnnotationComposer,
          $$CaptureRowsTableCreateCompanionBuilder,
          $$CaptureRowsTableUpdateCompanionBuilder,
          (
            CaptureRow,
            BaseReferences<_$AppDatabase, $CaptureRowsTable, CaptureRow>,
          ),
          CaptureRow,
          PrefetchHooks Function()
        > {
  $$CaptureRowsTableTableManager(_$AppDatabase db, $CaptureRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaptureRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaptureRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaptureRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<String?> course = const Value.absent(),
                Value<CaptureSource> source = const Value.absent(),
                Value<CaptureStatus> status = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<List<CaptureTerm>> terms = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<DateTime?> analyzedAt = const Value.absent(),
                Value<DateTime?> discardedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> mediaPath = const Value.absent(),
                Value<Set<CaptureSync>> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CaptureRowsCompanion(
                id: id,
                owner: owner,
                course: course,
                source: source,
                status: status,
                content: content,
                terms: terms,
                error: error,
                capturedAt: capturedAt,
                analyzedAt: analyzedAt,
                discardedAt: discardedAt,
                updatedAt: updatedAt,
                mediaPath: mediaPath,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String owner,
                Value<String?> course = const Value.absent(),
                required CaptureSource source,
                required CaptureStatus status,
                required String content,
                required List<CaptureTerm> terms,
                Value<String?> error = const Value.absent(),
                required DateTime capturedAt,
                Value<DateTime?> analyzedAt = const Value.absent(),
                Value<DateTime?> discardedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> mediaPath = const Value.absent(),
                required Set<CaptureSync> pending,
                Value<int> rowid = const Value.absent(),
              }) => CaptureRowsCompanion.insert(
                id: id,
                owner: owner,
                course: course,
                source: source,
                status: status,
                content: content,
                terms: terms,
                error: error,
                capturedAt: capturedAt,
                analyzedAt: analyzedAt,
                discardedAt: discardedAt,
                updatedAt: updatedAt,
                mediaPath: mediaPath,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CaptureRowsTable, CaptureRow>(table),
                  BaseReferences<_$AppDatabase, $CaptureRowsTable, CaptureRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CaptureRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaptureRowsTable,
      CaptureRow,
      $$CaptureRowsTableFilterComposer,
      $$CaptureRowsTableOrderingComposer,
      $$CaptureRowsTableAnnotationComposer,
      $$CaptureRowsTableCreateCompanionBuilder,
      $$CaptureRowsTableUpdateCompanionBuilder,
      (
        CaptureRow,
        BaseReferences<_$AppDatabase, $CaptureRowsTable, CaptureRow>,
      ),
      CaptureRow,
      PrefetchHooks Function()
    >;
typedef $$CaptureCursorsTableCreateCompanionBuilder =
    CaptureCursorsCompanion Function({
      required String owner,
      required DateTime updatedSince,
      Value<int> rowid,
    });
typedef $$CaptureCursorsTableUpdateCompanionBuilder =
    CaptureCursorsCompanion Function({
      Value<String> owner,
      Value<DateTime> updatedSince,
      Value<int> rowid,
    });

class $$CaptureCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $CaptureCursorsTable> {
  $$CaptureCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedSince => $composableBuilder(
    column: $table.updatedSince,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CaptureCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaptureCursorsTable> {
  $$CaptureCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedSince => $composableBuilder(
    column: $table.updatedSince,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CaptureCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaptureCursorsTable> {
  $$CaptureCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedSince => $composableBuilder(
    column: $table.updatedSince,
    builder: (column) => column,
  );
}

class $$CaptureCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaptureCursorsTable,
          CaptureCursor,
          $$CaptureCursorsTableFilterComposer,
          $$CaptureCursorsTableOrderingComposer,
          $$CaptureCursorsTableAnnotationComposer,
          $$CaptureCursorsTableCreateCompanionBuilder,
          $$CaptureCursorsTableUpdateCompanionBuilder,
          (
            CaptureCursor,
            BaseReferences<_$AppDatabase, $CaptureCursorsTable, CaptureCursor>,
          ),
          CaptureCursor,
          PrefetchHooks Function()
        > {
  $$CaptureCursorsTableTableManager(
    _$AppDatabase db,
    $CaptureCursorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaptureCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaptureCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaptureCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> owner = const Value.absent(),
                Value<DateTime> updatedSince = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CaptureCursorsCompanion(
                owner: owner,
                updatedSince: updatedSince,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String owner,
                required DateTime updatedSince,
                Value<int> rowid = const Value.absent(),
              }) => CaptureCursorsCompanion.insert(
                owner: owner,
                updatedSince: updatedSince,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CaptureCursorsTable, CaptureCursor>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CaptureCursorsTable,
                    CaptureCursor
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CaptureCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaptureCursorsTable,
      CaptureCursor,
      $$CaptureCursorsTableFilterComposer,
      $$CaptureCursorsTableOrderingComposer,
      $$CaptureCursorsTableAnnotationComposer,
      $$CaptureCursorsTableCreateCompanionBuilder,
      $$CaptureCursorsTableUpdateCompanionBuilder,
      (
        CaptureCursor,
        BaseReferences<_$AppDatabase, $CaptureCursorsTable, CaptureCursor>,
      ),
      CaptureCursor,
      PrefetchHooks Function()
    >;
typedef $$ReviewAttemptRowsTableCreateCompanionBuilder =
    ReviewAttemptRowsCompanion Function({
      required String id,
      required String owner,
      required String term,
      required ExerciseKind kind,
      Value<String?> exercise,
      required Outcome outcome,
      Value<int> rowid,
    });
typedef $$ReviewAttemptRowsTableUpdateCompanionBuilder =
    ReviewAttemptRowsCompanion Function({
      Value<String> id,
      Value<String> owner,
      Value<String> term,
      Value<ExerciseKind> kind,
      Value<String?> exercise,
      Value<Outcome> outcome,
      Value<int> rowid,
    });

class $$ReviewAttemptRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewAttemptRowsTable> {
  $$ReviewAttemptRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExerciseKind, ExerciseKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Outcome, Outcome, String> get outcome =>
      $composableBuilder(
        column: $table.outcome,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ReviewAttemptRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewAttemptRowsTable> {
  $$ReviewAttemptRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewAttemptRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewAttemptRowsTable> {
  $$ReviewAttemptRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExerciseKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get exercise =>
      $composableBuilder(column: $table.exercise, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Outcome, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);
}

class $$ReviewAttemptRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewAttemptRowsTable,
          ReviewAttemptRow,
          $$ReviewAttemptRowsTableFilterComposer,
          $$ReviewAttemptRowsTableOrderingComposer,
          $$ReviewAttemptRowsTableAnnotationComposer,
          $$ReviewAttemptRowsTableCreateCompanionBuilder,
          $$ReviewAttemptRowsTableUpdateCompanionBuilder,
          (
            ReviewAttemptRow,
            BaseReferences<
              _$AppDatabase,
              $ReviewAttemptRowsTable,
              ReviewAttemptRow
            >,
          ),
          ReviewAttemptRow,
          PrefetchHooks Function()
        > {
  $$ReviewAttemptRowsTableTableManager(
    _$AppDatabase db,
    $ReviewAttemptRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewAttemptRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewAttemptRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewAttemptRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<ExerciseKind> kind = const Value.absent(),
                Value<String?> exercise = const Value.absent(),
                Value<Outcome> outcome = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewAttemptRowsCompanion(
                id: id,
                owner: owner,
                term: term,
                kind: kind,
                exercise: exercise,
                outcome: outcome,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String owner,
                required String term,
                required ExerciseKind kind,
                Value<String?> exercise = const Value.absent(),
                required Outcome outcome,
                Value<int> rowid = const Value.absent(),
              }) => ReviewAttemptRowsCompanion.insert(
                id: id,
                owner: owner,
                term: term,
                kind: kind,
                exercise: exercise,
                outcome: outcome,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewAttemptRowsTable, ReviewAttemptRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReviewAttemptRowsTable,
                    ReviewAttemptRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewAttemptRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewAttemptRowsTable,
      ReviewAttemptRow,
      $$ReviewAttemptRowsTableFilterComposer,
      $$ReviewAttemptRowsTableOrderingComposer,
      $$ReviewAttemptRowsTableAnnotationComposer,
      $$ReviewAttemptRowsTableCreateCompanionBuilder,
      $$ReviewAttemptRowsTableUpdateCompanionBuilder,
      (
        ReviewAttemptRow,
        BaseReferences<
          _$AppDatabase,
          $ReviewAttemptRowsTable,
          ReviewAttemptRow
        >,
      ),
      ReviewAttemptRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CaptureRowsTableTableManager get captureRows =>
      $$CaptureRowsTableTableManager(_db, _db.captureRows);
  $$CaptureCursorsTableTableManager get captureCursors =>
      $$CaptureCursorsTableTableManager(_db, _db.captureCursors);
  $$ReviewAttemptRowsTableTableManager get reviewAttemptRows =>
      $$ReviewAttemptRowsTableTableManager(_db, _db.reviewAttemptRows);
}
