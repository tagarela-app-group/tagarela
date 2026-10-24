import 'package:flutter/widgets.dart';

import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';

typedef Json = Map<String, Object?>;

enum TermKind {
  word('Palavra'),
  expression('Expressão');

  const TermKind(this.label);

  final String label;
}

enum TermStatus {
  learning('Aprendendo'),
  mastered('Dominado');

  const TermStatus(this.label);

  final String label;
}

class User {
  const User({required this.name, required this.email, this.picture});

  User.fromJson(Json json)
    : this(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        picture: json['picture'] as String?,
      );

  final String name;
  final String email;
  final String? picture;

  Json toJson() => {'name': name, 'email': email, 'picture': ?picture};

  String get displayName => name.trim().isEmpty ? email : name.trim();

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final words = displayName.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final picked = words.length > 1 ? [words.first, words.last] : words;
    return picked.map((word) => word[0]).join().toUpperCase();
  }
}

class Stats {
  const Stats({required this.weekGain, required this.reviewCount});

  Stats.fromJson(Json json)
    : this(
        weekGain: json['weekGain']! as int,
        reviewCount: json['reviewCount']! as int,
      );

  final int weekGain;

  final int reviewCount;
}

class Term {
  const Term(this.text, this.translation, this.kind, this.level);

  Term.fromJson(Json json)
    : this(
        json['text']! as String,
        json['translation']! as String,
        TermKind.values.byName(json['kind']! as String),
        json['level']! as int,
      );

  final String text;
  final String translation;
  final TermKind kind;

  final int level;

  TermStatus get status =>
      level >= 4 ? TermStatus.mastered : TermStatus.learning;
}

class TermGroup {
  const TermGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.accent,
    required this.terms,
  });

  TermGroup.fromJson(Json json)
    : this(
        id: json['id']! as String,
        name: json['name']! as String,
        icon: _icons[json['icon']] ?? AppIcons.vocabulary,
        accent:
            AppAccent.values.asNameMap()[json['accent']] ?? AppAccent.violet,
        terms: [
          for (final t in json['terms']! as List<Object?>)
            Term.fromJson(t! as Json),
        ],
      );

  static const _icons = {
    'travel': AppIcons.travel,
    'work': AppIcons.work,
    'talk': AppIcons.talk,
    'layers': AppIcons.layers,
    'tv': AppIcons.tv,
    'food': AppIcons.food,
  };

  final String id;
  final String name;
  final IconData icon;
  final AppAccent accent;
  final List<Term> terms;

  int get masteredCount =>
      terms.where((t) => t.status == TermStatus.mastered).length;

  List<Term> termsWith(TermStatus? status) =>
      status == null ? terms : terms.where((t) => t.status == status).toList();
}

extension TermGroupList on List<TermGroup> {
  int get termCount => fold(0, (sum, g) => sum + g.terms.length);
  int get masteredCount => fold(0, (sum, g) => sum + g.masteredCount);
  int get learningCount => termCount - masteredCount;
}

class WordOfDay {
  const WordOfDay({
    required this.text,
    required this.phonetic,
    required this.partOfSpeech,
    required this.translation,
    required this.example,
    required this.dateLabel,
  });

  WordOfDay.fromJson(Json json)
    : this(
        text: json['text']! as String,
        phonetic: json['phonetic']! as String,
        partOfSpeech: json['partOfSpeech']! as String,
        translation: json['translation']! as String,
        example: json['example']! as String,
        dateLabel: json['dateLabel']! as String,
      );

  final String text;
  final String phonetic;
  final String partOfSpeech;
  final String translation;
  final String example;
  final String dateLabel;
}

enum CaptureSource {
  photo('Foto'),
  audio('Áudio'),
  text('Texto');

  const CaptureSource(this.label);

  final String label;
}

enum CaptureStatus {
  waitingFile('waiting_file'),
  processing('processing'),
  failed('failed'),
  ready('ready'),
  analyzed('analyzed');

  const CaptureStatus(this.apiName);

  final String apiName;

  static CaptureStatus fromApi(String name) =>
      values.firstWhere((s) => s.apiName == name);
}

enum CaptureSync { extract, create, file, update, confirm, discard }

enum CaptureSection {
  attention('Precisa de atenção'),
  ready('Prontas'),
  processing('Processando'),
  waiting('Esperando envio'),
  done('Analisadas');

  const CaptureSection(this.label);

  final String label;
}

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
    this.text = '',
    this.originalText = '',
    this.terms = const [],
    this.error,
    this.processedAt,
    this.analyzedAt,
    this.discardedAt,
    this.updatedAt,
    this.mediaPath,
    this.pending = const {},
  });

  Capture.fromJson(Json json)
    : this(
        id: json['id']! as String,
        source: CaptureSource.values.byName(json['source']! as String),
        status: CaptureStatus.fromApi(json['status']! as String),
        text: json['text']! as String,
        originalText: json['original_text']! as String,
        terms: [
          for (final t in json['terms']! as List<Object?>)
            CaptureTerm.fromJson(t! as Json),
        ],
        error: switch (json['error']) {
          final String e when e.isNotEmpty => e,
          _ => null,
        },
        capturedAt: DateTime.parse(json['captured_at']! as String),
        processedAt: _date(json['processed_at']),
        analyzedAt: _date(json['analyzed_at']),
        discardedAt: _date(json['discarded_at']),
        updatedAt: _date(json['updated_at']),
      );

  static const mediaRetention = Duration(days: 30);
  static const maxTextLength = 2000;

  final String id;
  final CaptureSource source;
  final CaptureStatus status;
  final String text;
  final String originalText;
  final List<CaptureTerm> terms;
  final String? error;
  final DateTime capturedAt;
  final DateTime? processedAt;
  final DateTime? analyzedAt;
  final DateTime? discardedAt;
  final DateTime? updatedAt;
  final String? mediaPath;
  final Set<CaptureSync> pending;

  CaptureSection get section => switch (status) {
    CaptureStatus.failed => CaptureSection.attention,
    CaptureStatus.ready => CaptureSection.ready,
    CaptureStatus.processing => CaptureSection.processing,
    CaptureStatus.waitingFile => CaptureSection.waiting,
    CaptureStatus.analyzed => CaptureSection.done,
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
      source: source,
      status: confirming ? status : server.status,
      text: editing ? text : server.text,
      originalText: server.originalText,
      terms: editing ? terms : server.terms,
      error: server.error,
      capturedAt: server.capturedAt,
      processedAt: server.processedAt,
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
    String? originalText,
    List<CaptureTerm>? terms,
    ValueGetter<String?>? error,
    DateTime? processedAt,
    DateTime? analyzedAt,
    DateTime? discardedAt,
    ValueGetter<String?>? mediaPath,
    Set<CaptureSync>? pending,
  }) => Capture(
    id: id,
    source: source,
    status: status ?? this.status,
    text: text ?? this.text,
    originalText: originalText ?? this.originalText,
    terms: terms ?? this.terms,
    error: error == null ? this.error : error(),
    capturedAt: capturedAt,
    processedAt: processedAt ?? this.processedAt,
    analyzedAt: analyzedAt ?? this.analyzedAt,
    discardedAt: discardedAt ?? this.discardedAt,
    updatedAt: updatedAt,
    mediaPath: mediaPath == null ? this.mediaPath : mediaPath(),
    pending: pending ?? this.pending,
  );

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.parse(value) : null;
}

class AuthTokens {
  const AuthTokens({required this.access, required this.refresh});

  AuthTokens.fromJson(Json json)
    : this(
        access: json['access_token']! as String,
        refresh: json['refresh_token']! as String,
      );

  final String access;
  final String refresh;
}
