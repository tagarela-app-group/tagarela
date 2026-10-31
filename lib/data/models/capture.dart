import 'package:flutter/foundation.dart';

import 'package:tagarela/data/models/json.dart';

enum CaptureSource { photo, audio, text }

enum CaptureStatus {
  processing('processing'),
  failed('failed'),
  ready('ready'),
  analyzed('analyzed');

  const CaptureStatus(this.apiName);

  final String apiName;

  static CaptureStatus fromApi(String name) =>
      values.firstWhere((s) => s.apiName == name);
}

enum CaptureSync { extract, create, update, confirm, discard }

enum CaptureSection { attention, ready, processing }

class CaptureTerm {
  const CaptureTerm({
    required this.text,
    required this.start,
    required this.end,
  });

  CaptureTerm.fromJson(Json json)
    : this(
        text: json['text']! as String,
        start: json['start']! as int,
        end: json['end']! as int,
      );

  final String text;
  final int start;
  final int end;

  Json toJson() => {'text': text, 'start': start, 'end': end};

  @override
  bool operator ==(Object other) =>
      other is CaptureTerm &&
      other.text == text &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(text, start, end);
}

class Capture {
  const Capture({
    required this.id,
    required this.source,
    required this.status,
    required this.capturedAt,
    this.course,
    this.text = '',
    this.terms = const [],
    this.error,
    this.analyzedAt,
    this.discardedAt,
    this.updatedAt,
    this.mediaPath,
    this.pending = const {},
  });

  Capture.fromJson(Json json)
    : this(
        id: json['id']! as String,
        course: json['course'] as String?,
        source: CaptureSource.values.byName(json['source']! as String),
        status: CaptureStatus.fromApi(json['status']! as String),
        text: json['text']! as String,
        terms: [
          for (final t in json['terms']! as List<Object?>)
            CaptureTerm.fromJson(t! as Json),
        ],
        capturedAt: DateTime.parse(json['captured_at']! as String),
        analyzedAt: _date(json['analyzed_at']),
        discardedAt: _date(json['discarded_at']),
        updatedAt: _date(json['updated_at']),
      );

  static const mediaRetention = Duration(days: 30);
  static const maxTextLength = 2000;

  final String id;
  final String? course;
  final CaptureSource source;
  final CaptureStatus status;
  final String text;
  final List<CaptureTerm> terms;
  final String? error;
  final DateTime capturedAt;
  final DateTime? analyzedAt;
  final DateTime? discardedAt;
  final DateTime? updatedAt;
  final String? mediaPath;
  final Set<CaptureSync> pending;

  CaptureSection? get section => switch (status) {
    CaptureStatus.failed => CaptureSection.attention,
    CaptureStatus.ready => CaptureSection.ready,
    CaptureStatus.processing => CaptureSection.processing,
    CaptureStatus.analyzed => null,
  };

  bool get needsAction =>
      status == CaptureStatus.ready || status == CaptureStatus.failed;

  bool get waitsExtraction =>
      status == CaptureStatus.processing &&
      pending.contains(CaptureSync.extract);

  bool mediaExpired(DateTime now) {
    final closedAt = analyzedAt ?? discardedAt;
    return mediaPath != null &&
        closedAt != null &&
        now.difference(closedAt) > mediaRetention;
  }

  Capture merge(Capture server) {
    final editing = pending.contains(CaptureSync.update);
    final confirming = pending.contains(CaptureSync.confirm);
    return Capture(
      id: id,
      course: server.course ?? course,
      source: source,
      status: confirming ? status : server.status,
      text: editing ? text : server.text,
      terms: editing ? terms : server.terms,
      error: server.error,
      capturedAt: server.capturedAt,
      analyzedAt: confirming ? analyzedAt : server.analyzedAt,
      discardedAt: pending.contains(CaptureSync.discard)
          ? discardedAt
          : server.discardedAt,
      updatedAt: server.updatedAt,
      mediaPath: mediaPath,
      pending: pending,
    );
  }

  Capture copyWith({
    CaptureStatus? status,
    String? text,
    List<CaptureTerm>? terms,
    ValueGetter<String?>? error,
    DateTime? analyzedAt,
    DateTime? discardedAt,
    ValueGetter<String?>? mediaPath,
    Set<CaptureSync>? pending,
  }) => Capture(
    id: id,
    course: course,
    source: source,
    status: status ?? this.status,
    text: text ?? this.text,
    terms: terms ?? this.terms,
    error: error == null ? this.error : error(),
    capturedAt: capturedAt,
    analyzedAt: analyzedAt ?? this.analyzedAt,
    discardedAt: discardedAt ?? this.discardedAt,
    updatedAt: updatedAt,
    mediaPath: mediaPath == null ? this.mediaPath : mediaPath(),
    pending: pending ?? this.pending,
  );

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.parse(value) : null;
}
