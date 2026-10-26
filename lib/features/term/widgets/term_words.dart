import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/logic/card_text.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermWords extends StatelessWidget {
  const TermWords({
    super.key,
    required this.card,
    required this.term,
    required this.language,
    required this.voice,
  });

  final TermCard card;
  final String term;
  final CourseLanguage language;
  final Voice voice;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final locale = Locale(language.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s3,
      children: [
        if (card.collocations.isNotEmpty)
          AppCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s4,
              AppSpacing.s4,
              AppSpacing.s4,
              10,
            ),
            child: ListenableBuilder(
              listenable: voice,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(l10n.collocations, style: AppText.titleSm),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.s1,
                      bottom: AppSpacing.s2,
                    ),
                    child: Text(
                      l10n.collocationsHint,
                      style: AppText.label.copyWith(
                        color: c.inkSoft,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  for (final phrase in card.collocations)
                    _Combo(
                      pieces: phrasePieces(phrase, term),
                      locale: locale,
                      saying: voice.speaking != null && voice.text == phrase,
                      label: l10n.listenTo(phrase),
                      onListen: () => voice.text == phrase
                          ? voice.stop()
                          : voice.speak(phrase, language),
                    ),
                ],
              ),
            ),
          ),
        if (card.synonyms.isNotEmpty || card.antonyms.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s4,
              children: [
                Semantics(
                  header: true,
                  child: Text(l10n.neighbors, style: AppText.titleSm),
                ),
                if (card.synonyms.isNotEmpty)
                  _Neighbors(
                    sign: '≈',
                    title: l10n.synonyms,
                    words: card.synonyms,
                    muted: false,
                  ),
                if (card.antonyms.isNotEmpty)
                  _Neighbors(
                    sign: '≠',
                    title: l10n.antonyms,
                    words: card.antonyms,
                    muted: true,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Combo extends StatelessWidget {
  const _Combo({
    required this.pieces,
    required this.locale,
    required this.saying,
    required this.label,
    required this.onListen,
  });

  final List<Part> pieces;
  final Locale locale;
  final bool saying;
  final String label;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Row(
          spacing: AppSpacing.s2,
          children: [
            Expanded(
              child: AnimatedSlide(
                duration: AppMotion.base,
                curve: AppMotion.spring,
                offset: saying ? const Offset(0.02, 0) : Offset.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
                  child: Wrap(
                    spacing: AppSpacing.s1,
                    runSpacing: AppSpacing.s1,
                    children: [
                      for (final piece in pieces)
                        Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s3,
                          ),
                          decoration: BoxDecoration(
                            color: piece.marked ? c.primary : c.surfaceAlt,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            boxShadow: piece.marked ? c.buttonShadow : null,
                          ),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              piece.text,
                              locale: locale,
                              style: AppText.bodyLg.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: piece.marked ? c.onPrimary : c.ink,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            AppIconButton(
              icon: saying ? AppIcons.stop : AppIcons.listen,
              tooltip: label,
              onPressed: onListen,
            ),
          ],
        ),
      ),
    );
  }
}

class _Neighbors extends StatelessWidget {
  const _Neighbors({
    required this.sign,
    required this.title,
    required this.words,
    required this.muted,
  });

  final String sign;
  final String title;
  final List<String> words;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s2,
      children: [
        Row(
          spacing: AppSpacing.s2,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: muted ? c.surfaceAlt : c.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  sign,
                  style: AppText.titleSm.copyWith(
                    height: 1,
                    color: muted ? c.ink : c.primaryText,
                  ),
                ),
              ),
            ),
            Semantics(
              header: true,
              child: Text(
                title,
                style: AppText.label.copyWith(color: c.inkSoft),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final word in words) TermChip(label: word, muted: muted),
          ],
        ),
      ],
    );
  }
}
