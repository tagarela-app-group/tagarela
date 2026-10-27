import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/practice_page.dart';
import 'package:tagarela/features/practice/widgets/practice_cards.dart';
import 'package:tagarela/features/term/widgets/meaning_card.dart';
import 'package:tagarela/features/term/widgets/term_building.dart';
import 'package:tagarela/features/term/widgets/seen_captures.dart';
import 'package:tagarela/features/term/widgets/term_dialogue.dart';
import 'package:tagarela/features/term/widgets/term_examples.dart';
import 'package:tagarela/features/term/widgets/term_header.dart';
import 'package:tagarela/features/term/widgets/term_reminders.dart';
import 'package:tagarela/features/term/widgets/term_usage.dart';
import 'package:tagarela/features/term/widgets/term_words.dart';
import 'package:tagarela/l10n/l10n.dart';

enum _Tab { context, words, usage }

class TermPage extends StatefulWidget {
  const TermPage({super.key, required this.term});

  final Term term;

  static Future<void> open(BuildContext context, Term term) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => TermPage(term: term)));

  @override
  State<TermPage> createState() => _TermPageState();
}

class _TermPageState extends State<TermPage> {
  TermDetail? _detail;
  Object? _error;
  var _revealed = false;
  var _flipped = false;
  var _bursts = 0;
  var _asked = false;
  var _pitfallRevealed = false;
  var _pitfallBursts = 0;
  var _formalityRevealed = false;
  var _tab = _Tab.context;
  late final Voice _voice;

  @override
  void initState() {
    super.initState();
    _voice = AppScope.of(context).voice;
    _load();
  }

  Future<void> _load() async {
    final vocabulary = AppScope.of(context).vocabulary;
    if (_error != null) setState(() => _error = null);
    try {
      final detail = await vocabulary.term(widget.term.id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _revealed = detail.revealed;
        _pitfallRevealed = detail.pitfallRevealed;
        _formalityRevealed = detail.formalityRevealed;
      });
    } on Exception catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _reveal(bool revealed) {
    if (revealed == _revealed) return;
    setState(() {
      _revealed = revealed;
      _asked = revealed;
      if (revealed) _bursts++;
    });
    _save(
      () => AppScope.of(
        context,
      ).vocabulary.reveal(widget.term.id, revealed: revealed),
    );
  }

  void _revealPitfall(bool revealed) {
    if (revealed == _pitfallRevealed) return;
    setState(() {
      _pitfallRevealed = revealed;
      if (revealed) _pitfallBursts++;
    });
    _save(
      () => AppScope.of(
        context,
      ).vocabulary.reveal(widget.term.id, pitfallRevealed: revealed),
    );
  }

  void _revealFormality(bool revealed) {
    if (revealed == _formalityRevealed) return;
    setState(() => _formalityRevealed = revealed);
    _save(
      () => AppScope.of(
        context,
      ).vocabulary.reveal(widget.term.id, formalityRevealed: revealed),
    );
  }

  Future<void> _save(Future<TermDetail> Function() reveal) async {
    try {
      await reveal();
    } on Exception {
      return;
    }
  }

  void _openTerm(String id) {
    final vocabulary = AppScope.of(context).vocabulary.data;
    final term = [
      ...?vocabulary?.ungrouped,
      for (final g in vocabulary?.groups ?? const <TermGroup>[]) ...g.terms,
    ].where((t) => t.id == id).firstOrNull;
    if (term != null) TermPage.open(context, term);
  }

  @override
  void dispose() {
    _voice.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final course = scope.courses.active;
    final learning = course?.learning ?? CourseLanguage.en;
    final base = course?.base ?? CourseLanguage.pt;
    final detail = _detail;
    final group =
        detail?.group ??
        scope.vocabulary.data?.groups
            .where((g) => g.terms.any((t) => t.id == widget.term.id))
            .firstOrNull;

    if (detail == null && _error == null) {
      return AppPage(
        sheet: false,
        header: TermBuilding(
          term: widget.term,
          group: group,
          language: learning,
        ),
      );
    }

    return AppPage(
      header: TermHeader(
        term: detail?.term ?? widget.term,
        group: group,
        phonetic: detail?.card.phonetic,
        language: learning,
        voice: _voice,
      ),
      gap: AppSpacing.s6,
      centerLast: _error != null,
      children: switch (detail) {
        final detail? => _sections(detail, learning, base),
        null => [AsyncStatus(error: _error!, onRetry: _load)],
      },
    );
  }

  List<Widget> _sections(
    TermDetail detail,
    CourseLanguage learning,
    CourseLanguage base,
  ) {
    final l10n = context.l10n;
    final card = detail.card;
    final locale = Locale(learning.name);
    final tabs = [
      if (detail.captures.isNotEmpty ||
          card.dialogue.isNotEmpty ||
          card.examples.isNotEmpty)
        _Tab.context,
      if (card.hasWords) _Tab.words,
      if (card.hasUsage) _Tab.usage,
    ];
    final tab = tabs.contains(_tab) ? _tab : tabs.firstOrNull;
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s1,
        children: [
          SectionLabel(label: l10n.meaning),
          MeaningCard(
            card: card,
            learning: learning,
            base: base,
            flipped: _flipped,
            onFlip: () => setState(() => _flipped = !_flipped),
          ),
        ],
      ),
      if (card.hasReminders)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s1,
          children: [
            SectionLabel(
              label: l10n.remember,
              action: card.hasReveal
                  ? AppButton(
                      label: _revealed ? l10n.coverAgain : l10n.reveal,
                      leading: Icon(
                        _revealed ? AppIcons.cover : AppIcons.reveal,
                        size: 16,
                      ),
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.small,
                      onPressed: () => _reveal(!_revealed),
                    )
                  : null,
            ),
            TermReminders(
              card: card,
              learning: learning,
              base: base,
              revealed: _revealed,
              asked: _revealed && _asked,
              bursts: _bursts,
              onReveal: () => _reveal(true),
              pitfallRevealed: _pitfallRevealed,
              pitfallBursts: _pitfallBursts,
              onPitfallReveal: _revealPitfall,
            ),
          ],
        ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s1,
        children: [
          SectionLabel(label: l10n.practiceSection),
          PracticeCards(
            onOpen: (kind) => PracticePage.openTerm(context, detail.term, kind),
          ),
        ],
      ),
      if (tab != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            if (tabs.length > 1)
              SegmentedControl(
                options: [for (final t in tabs) l10n.termTab(t.name)],
                selected: tabs.indexOf(tab),
                onChanged: (i) => setState(() => _tab = tabs[i]),
              ),
            switch (tab) {
              _Tab.context => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.s5,
                children: [
                  if (detail.captures.isNotEmpty)
                    SeenCaptures(
                      captures: detail.captures,
                      termId: detail.term.id,
                      locale: locale,
                      onOpenTerm: _openTerm,
                    ),
                  if (card.dialogue.isNotEmpty)
                    TermDialogue(
                      lines: card.dialogue,
                      term: detail.term.text,
                      learning: learning,
                      base: base,
                      voice: _voice,
                    )
                  else if (card.examples.isNotEmpty)
                    TermExamples(
                      examples: card.examples,
                      term: detail.term.text,
                      locale: locale,
                      translated: _flipped,
                    ),
                ],
              ),
              _Tab.words => TermWords(
                card: card,
                term: detail.term.text,
                language: learning,
                voice: _voice,
              ),
              _Tab.usage => TermUsage(
                card: card,
                learning: learning,
                base: base,
                noteRevealed: _formalityRevealed,
                onNoteReveal: _revealFormality,
              ),
            },
          ],
        ),
    ];
  }
}
