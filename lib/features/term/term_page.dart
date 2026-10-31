import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/practice_page.dart';
import 'package:tagarela/features/term/logic/term_controller.dart';
import 'package:tagarela/shared/widgets/practice_cards.dart';
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
  late final TermController _term;
  late final Voice _voice;

  @override
  void initState() {
    super.initState();
    final scope = AppScope.of(context);
    _voice = scope.voice;
    _term = TermController(scope.vocabulary, widget.term.id)..load();
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
    _term.dispose();
    _voice.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: _term, builder: (context, _) => _page());

  Widget _page() {
    final scope = AppScope.of(context);
    final course = scope.courses.active;
    final learning = course?.learning ?? CourseLanguage.en;
    final base = course?.base ?? CourseLanguage.pt;
    final detail = _term.detail;
    final error = _term.error;
    final group =
        detail?.group ??
        scope.vocabulary.data?.groups
            .where((g) => g.terms.any((t) => t.id == widget.term.id))
            .firstOrNull;

    if (detail == null && error == null) {
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
      centerLast: error != null,
      children: switch (detail) {
        final detail? => _sections(detail, learning, base),
        null => [AsyncStatus(error: error, onRetry: _term.load)],
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
    final tabs = _term.tabs;
    final tab = _term.tab;
    final revealed = _term.revealed(TermNote.remember);
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
            flipped: _term.flipped,
            onFlip: _term.flip,
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
                      label: revealed ? l10n.coverAgain : l10n.reveal,
                      leading: Icon(
                        revealed ? AppIcons.cover : AppIcons.reveal,
                        size: AppIconSize.sm,
                      ),
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.small,
                      onPressed: () =>
                          _term.reveal(TermNote.remember, revealed: !revealed),
                    )
                  : null,
            ),
            TermReminders(
              card: card,
              learning: learning,
              base: base,
              revealed: revealed,
              asked: revealed && _term.asked,
              bursts: _term.bursts(TermNote.remember),
              onReveal: () => _term.reveal(TermNote.remember, revealed: true),
              pitfallRevealed: _term.revealed(TermNote.pitfall),
              pitfallBursts: _term.bursts(TermNote.pitfall),
              onPitfallReveal: (revealed) =>
                  _term.reveal(TermNote.pitfall, revealed: revealed),
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
          spacing: AppSpacing.s35,
          children: [
            if (tabs.length > 1)
              SegmentedControl(
                options: [for (final t in tabs) l10n.termTab(t.name)],
                selected: tabs.indexOf(tab),
                onChanged: (i) => _term.select(tabs[i]),
              ),
            switch (tab) {
              TermTab.context => Column(
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
                      translated: _term.flipped,
                    ),
                ],
              ),
              TermTab.words => TermWords(
                card: card,
                term: detail.term.text,
                language: learning,
                voice: _voice,
              ),
              TermTab.usage => TermUsage(
                card: card,
                learning: learning,
                base: base,
                noteRevealed: _term.revealed(TermNote.formality),
                onNoteReveal: (revealed) =>
                    _term.reveal(TermNote.formality, revealed: revealed),
              ),
            },
          ],
        ),
    ];
  }
}
