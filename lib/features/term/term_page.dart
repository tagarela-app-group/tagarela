import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/voice.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/widgets/meaning_card.dart';
import 'package:tagarela/features/term/widgets/seen_captures.dart';
import 'package:tagarela/features/term/widgets/term_examples.dart';
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
    setState(() {
      _revealed = revealed;
      if (!revealed) _flipped = false;
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

    return SheetPage(
      header: _TermHeader(
        term: detail?.term ?? widget.term,
        group: group,
        phonetic: detail?.card.phonetic,
        language: learning,
        voice: _voice,
      ),
      gap: AppSpacing.s6,
      centerLast: detail == null,
      children: detail == null
          ? [
              _error == null
                  ? const _Building()
                  : AsyncStatus(error: _error, onRetry: _load),
            ]
          : _sections(detail, learning, base),
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
      if (detail.captures.isNotEmpty || card.examples.isNotEmpty) _Tab.context,
      if (card.hasWords) _Tab.words,
      if (card.hasUsage) _Tab.usage,
    ];
    final tab = tabs.contains(_tab) ? _tab : tabs.firstOrNull;
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s1,
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.meaning.toUpperCase(),
                      style: AppText.overline.copyWith(
                        color: context.colors.inkSoft,
                      ),
                    ),
                  ),
                ),
                if (_revealed)
                  AppButton(
                    label: l10n.coverAgain,
                    leading: const Icon(AppIcons.cover, size: 16),
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
                    onPressed: () => _reveal(false),
                  ),
              ],
            ),
          ),
          MeaningCard(
            card: card,
            learning: learning,
            base: base,
            revealed: _revealed,
            flipped: _flipped,
            onReveal: () => _reveal(true),
            onFlip: () => setState(() => _flipped = !_flipped),
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
                  if (card.examples.isNotEmpty)
                    TermExamples(
                      examples: card.examples,
                      term: detail.term.text,
                      locale: locale,
                      translated: _revealed && _flipped,
                    ),
                ],
              ),
              _Tab.words => TermWords(card: card),
              _Tab.usage => TermUsage(card: card),
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
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: Column(
        spacing: AppSpacing.s4,
        children: [
          CircularProgressIndicator(color: c.primary),
          Text(
            context.l10n.termCardLoading,
            style: AppText.bodyMd.copyWith(color: c.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _TermHeader extends StatelessWidget {
  const _TermHeader({
    required this.term,
    required this.group,
    required this.phonetic,
    required this.language,
    required this.voice,
  });

  final Term term;
  final TermGroup? group;
  final String? phonetic;
  final CourseLanguage language;
  final Voice voice;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final mastered = term.status == TermStatus.mastered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 18,
      children: [
        AppIconButton(
          icon: AppIcons.back,
          tooltip: l10n.back,
          onPressed: () => Navigator.of(context).pop(),
          variant: AppIconButtonVariant.onHeader,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              spacing: AppSpacing.s2,
              children: [
                AppTag(label: l10n.termKind(term.kind.name), onHeader: true),
                Flexible(
                  child: HeaderPill(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5,
                      children: [
                        Icon(group?.icon ?? AppIcons.ungrouped, size: 13),
                        Flexible(
                          child: Text(
                            group?.name ?? l10n.ungrouped,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Text(
              term.text,
              locale: Locale(language.name),
              style: AppText.display.copyWith(color: AppPalette.white),
            ),
            if (phonetic case final phonetic?)
              Text(
                phonetic,
                style: AppText.bodyLg.copyWith(
                  fontSize: 17,
                  color: c.onHeaderSoft,
                ),
              ),
          ],
        ),
        ListenableBuilder(
          listenable: voice,
          builder: (context, _) {
            final speaking = voice.speaking;
            void speak(VoiceSpeed speed) => speaking == speed
                ? voice.stop()
                : voice.speak(term.text, language, speed: speed);
            return Row(
              spacing: 10,
              children: [
                AppIconButton(
                  icon: speaking == VoiceSpeed.normal
                      ? AppIcons.stop
                      : AppIcons.listen,
                  tooltip: speaking == VoiceSpeed.normal
                      ? l10n.stop
                      : l10n.listenPronunciation,
                  onPressed: () => speak(VoiceSpeed.normal),
                  variant: AppIconButtonVariant.onHeaderSolid,
                  size: 56,
                ),
                AppButton(
                  label: l10n.listenSlow,
                  variant: AppButtonVariant.onHeader,
                  size: AppButtonSize.small,
                  leading: speaking == VoiceSpeed.slow
                      ? const Icon(AppIcons.stop, size: 18)
                      : null,
                  onPressed: () => speak(VoiceSpeed.slow),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 6,
                  children: [
                    StatusPill(
                      label: l10n.termStatus(term.status.name),
                      tone: mastered
                          ? StatusTone.mastered
                          : StatusTone.learning,
                    ),
                    LevelDots(
                      level: term.level,
                      color: mastered ? c.mastered : c.learning,
                      track: c.headerChip,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
