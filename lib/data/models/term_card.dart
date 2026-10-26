import 'package:tagarela/data/models/capture.dart';
import 'package:tagarela/data/models/json.dart';
import 'package:tagarela/data/models/term.dart';
import 'package:tagarela/data/models/vocabulary.dart';

enum Formality { slang, informal, neutral, formal }

enum DialogueSpeaker { a, b }

class CardSide {
  const CardSide({
    this.headline,
    this.inContext,
    this.explanation,
    this.pitfall,
    this.literal,
    this.imagine,
  });

  final String? headline;
  final String? inContext;
  final String? explanation;
  final String? pitfall;
  final String? literal;
  final String? imagine;
}

class CardMistake {
  const CardMistake(this.wrong, this.right);

  final String wrong;
  final String right;
}

class DialogueLine {
  const DialogueLine({
    required this.speaker,
    required this.text,
    required this.translation,
  });

  final DialogueSpeaker speaker;
  final String text;
  final String translation;
}

class CardExample {
  const CardExample(this.text, this.translation);

  final String text;
  final String translation;
}

class UsageFit {
  const UsageFit({required this.context, required this.fits, this.instead});

  final String context;
  final bool fits;
  final String? instead;
}

class TermCard {
  const TermCard({
    this.phonetic,
    this.learning = const CardSide(),
    this.base = const CardSide(),
    this.examples = const [],
    this.mistake,
    this.dialogue = const [],
    this.collocations = const [],
    this.synonyms = const [],
    this.antonyms = const [],
    this.formality,
    this.formalityNote,
    this.fits = const [],
  });

  TermCard.fromJson(Json json)
    : this(
        phonetic: json['phonetic'] as String?,
        learning: CardSide(
          headline: (json['learning']! as Json)['definition'] as String?,
          inContext: (json['learning']! as Json)['in_context'] as String?,
          explanation: (json['learning']! as Json)['explanation'] as String?,
        ),
        base: CardSide(
          headline: (json['base']! as Json)['translation'] as String?,
          inContext: (json['base']! as Json)['in_context'] as String?,
          explanation: (json['base']! as Json)['explanation'] as String?,
          pitfall: (json['base']! as Json)['pitfall'] as String?,
          literal: (json['base']! as Json)['literal'] as String?,
          imagine: (json['base']! as Json)['imagine'] as String?,
        ),
        mistake: switch (json['mistake']) {
          final Json m => CardMistake(
            m['wrong']! as String,
            m['right']! as String,
          ),
          _ => null,
        },
        dialogue: [
          for (final d in (json['dialogue']! as List<Object?>).cast<Json>())
            DialogueLine(
              speaker: DialogueSpeaker.values.byName(
                (d['speaker']! as String).toLowerCase(),
              ),
              text: d['text']! as String,
              translation: d['translation']! as String,
            ),
        ],
        examples: [
          for (final e in (json['examples']! as List<Object?>).cast<Json>())
            CardExample(e['text']! as String, e['translation']! as String),
        ],
        collocations: _strings(json['collocations']),
        synonyms: _strings(json['synonyms']),
        antonyms: _strings(json['antonyms']),
        formality: Formality.values.asNameMap()[json['formality']],
        formalityNote: json['formality_note'] as String?,
        fits: [
          for (final f in (json['fits']! as List<Object?>).cast<Json>())
            UsageFit(
              context: f['context']! as String,
              fits: f['fits']! as bool,
              instead: f['alternative'] as String?,
            ),
        ],
      );

  final String? phonetic;
  final CardSide learning;
  final CardSide base;
  final List<CardExample> examples;
  final CardMistake? mistake;
  final List<DialogueLine> dialogue;
  final List<String> collocations;
  final List<String> synonyms;
  final List<String> antonyms;
  final Formality? formality;
  final String? formalityNote;
  final List<UsageFit> fits;

  bool get hasWords =>
      collocations.isNotEmpty || synonyms.isNotEmpty || antonyms.isNotEmpty;

  bool get hasUsage => formality != null || fits.isNotEmpty;

  bool get hasReminders =>
      base.literal != null ||
      base.imagine != null ||
      base.pitfall != null ||
      mistake != null;

  static List<String> _strings(Object? json) => [
    for (final s in json! as List<Object?>) s! as String,
  ];
}

class CaptureSpan {
  const CaptureSpan({
    required this.text,
    required this.start,
    required this.end,
    this.termId,
  });

  final String text;
  final int start;
  final int end;
  final String? termId;
}

class SeenCapture {
  const SeenCapture({
    required this.id,
    required this.source,
    required this.text,
    required this.capturedAt,
    this.spans = const [],
  });

  SeenCapture.fromJson(Json json)
    : this(
        id: json['id']! as String,
        source: CaptureSource.values.byName(json['source']! as String),
        text: json['text']! as String,
        capturedAt: DateTime.parse(json['captured_at']! as String),
        spans: [
          for (final t in (json['terms']! as List<Object?>).cast<Json>())
            CaptureSpan(
              text: t['text']! as String,
              start: t['start']! as int,
              end: t['end']! as int,
              termId: t['term'] as String?,
            ),
        ],
      );

  final String id;
  final CaptureSource source;
  final String text;
  final DateTime capturedAt;
  final List<CaptureSpan> spans;
}

class TermDetail {
  const TermDetail({
    required this.term,
    required this.card,
    this.group,
    this.revealed = false,
    this.captures = const [],
  });

  TermDetail.fromJson(Json json)
    : this(
        term: Term.fromJson(json),
        group: switch (json['group']) {
          final Json group => TermGroup.fromJson({...group, 'terms': []}),
          _ => null,
        },
        revealed: json['revealed']! as bool,
        card: TermCard.fromJson(json['card']! as Json),
        captures: [
          for (final c in json['captures']! as List<Object?>)
            SeenCapture.fromJson(c! as Json),
        ],
      );

  final Term term;
  final TermGroup? group;
  final bool revealed;
  final TermCard card;
  final List<SeenCapture> captures;
}
