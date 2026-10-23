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
  camera('Câmera'),
  audio('Áudio'),
  text('Texto');

  const CaptureSource(this.label);

  final String label;
}

enum InboxStatus { ready, analyzing, queued }

class InboxItem {
  const InboxItem({
    required this.id,
    required this.source,
    required this.content,
    required this.capturedAt,
    required this.status,
    this.suggestion,
  });

  InboxItem.fromJson(Json json)
    : this(
        id: json['id']! as String,
        source: CaptureSource.values.byName(json['source']! as String),
        content: json['content']! as String,
        capturedAt: json['capturedAt']! as String,
        status: InboxStatus.values.byName(json['status']! as String),
        suggestion: switch (json['suggestion']) {
          final Json s => Suggestion.fromJson(s),
          _ => null,
        },
      );

  final String id;
  final CaptureSource source;

  final String content;

  final String capturedAt;
  final InboxStatus status;
  final Suggestion? suggestion;
}

class Suggestion {
  const Suggestion(this.translation, this.kind, this.groupId, this.groupName);

  Suggestion.fromJson(Json json)
    : this(
        json['translation']! as String,
        TermKind.values.byName(json['kind']! as String),
        json['groupId']! as String,
        json['groupName']! as String,
      );

  final String translation;
  final TermKind kind;
  final String groupId;
  final String groupName;
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
