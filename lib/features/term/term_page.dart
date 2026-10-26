import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/widgets/meaning_card.dart';
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
  var _tab = _Tab.context;
  late final _voice = AppScope.of(context).voice;

  @override
  void initState() {
    super.initState();
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
    _save(revealed);
  }

  Future<void> _save(bool revealed) async {
    try {
      await AppScope.of(
        context,
      ).vocabulary.reveal(widget.term.id, revealed: revealed);
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

    return AppPage(
      header: TermHeader(
        term: detail?.term ?? widget.term,
        group: group,
        phonetic: detail?.card.phonetic,
        loading: detail == null && _error == null,
        language: learning,
        voice: _voice,
      ),
      gap: AppSpacing.s6,
      centerLast: _error != null,
      children: switch ((detail, _error)) {
        (final detail?, _) => _sections(detail, learning, base),
        (null, null) => const [_Building()],
        (null, final error) => [AsyncStatus(error: error, onRetry: _load)],
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
                term: detail.term.text,
                language: learning,
              ),
            },
          ],
        ),
    ];
  }
}

class _Building extends StatelessWidget {
  const _Building();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.termCardLoading,
      child: const ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s6,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s1,
              children: [
                SizedBox(
                  height: 44,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Skeleton(width: 96, height: 12),
                  ),
                ),
                AppCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.s4,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppSpacing.s2,
                        children: [
                          Skeleton(width: 72, height: 10),
                          Skeleton(width: 180, height: 22),
                        ],
                      ),
                      _Lines(lines: 2),
                      _Lines(lines: 3),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                Skeleton(height: 44, radius: AppRadius.md),
                AppCard(
                  padding: EdgeInsets.all(AppSpacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.s3,
                    children: [
                      Row(
                        spacing: AppSpacing.s2,
                        children: [
                          Skeleton(width: 28, height: 28, radius: AppRadius.sm),
                          Skeleton(width: 120, height: 12),
                        ],
                      ),
                      _Lines(lines: 2, title: false),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Lines extends StatelessWidget {
  const _Lines({required this.lines, this.title = true});

  final int lines;
  final bool title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s2,
      children: [
        if (title) const Skeleton(width: 110, height: 10),
        for (var i = 0; i < lines; i++)
          FractionallySizedBox(
            widthFactor: i == lines - 1 ? 0.6 : 1,
            child: const Skeleton(),
          ),
      ],
    );
  }
}
