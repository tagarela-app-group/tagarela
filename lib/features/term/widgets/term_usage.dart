import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermUsage extends StatelessWidget {
  const TermUsage({
    super.key,
    required this.card,
    required this.term,
    required this.language,
  });

  static const _tilts = [-0.035, 0.026, -0.017, 0.03];

  final TermCard card;
  final String term;
  final CourseLanguage language;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final formality = card.formality;
    final locale = Locale(language.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s3,
      children: [
        if (formality != null)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s3,
              children: [
                Semantics(
                  header: true,
                  child: Text(l10n.formality, style: AppText.titleSm),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 10,
                  children: [
                    DrawnIcon(DrawnGlyph.sandal, size: 26, color: c.inkSoft),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 10,
                        children: [
                          ExcludeSemantics(
                            child: Row(
                              children: [
                                for (final level in Formality.values)
                                  Expanded(
                                    child: SizedBox(
                                      height: 24,
                                      child: level == formality
                                          ? OverflowBox(
                                              maxWidth: double.infinity,
                                              child: SpeechBalloon(
                                                color: c.primary,
                                                radius: AppRadius.sm,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 9,
                                                      vertical: 3,
                                                    ),
                                                child: Text(
                                                  term,
                                                  locale: locale,
                                                  maxLines: 1,
                                                  style: AppText.pill.copyWith(
                                                    color: c.onPrimary,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SegmentBar(
                            height: 10,
                            semanticLabel: l10n.formalityMeter(
                              l10n.formalityLevel(formality.name),
                              formality.index + 1,
                            ),
                            segments: [
                              for (final level in Formality.values)
                                Segment(
                                  1,
                                  level.index <= formality.index
                                      ? c.primary
                                      : c.surfaceAlt,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DrawnIcon(DrawnGlyph.tie, size: 26, color: c.inkSoft),
                  ],
                ),
                ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Row(
                      spacing: AppSpacing.s1,
                      children: [
                        for (final level in Formality.values)
                          Expanded(
                            child: Text(
                              l10n.formalityLevel(level.name),
                              textAlign: TextAlign.center,
                              style: AppText.caption.copyWith(
                                color: level == formality
                                    ? c.primaryText
                                    : c.inkSoft,
                                fontWeight: level == formality
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (card.formalityNote case final note?)
                  Text(
                    note,
                    locale: locale,
                    style: AppText.bodyMd.copyWith(color: c.inkSoft),
                  ),
              ],
            ),
          ),
        if (card.fits.isNotEmpty)
          AppCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s4,
              AppSpacing.s4,
              AppSpacing.s4,
              AppSpacing.s5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                Semantics(
                  header: true,
                  child: Text(l10n.whereItFits, style: AppText.titleSm),
                ),
                Wrap(
                  spacing: AppSpacing.s2,
                  runSpacing: 10,
                  children: [
                    for (final (i, fit) in card.fits.indexed)
                      Transform.rotate(
                        angle: _tilts[i % _tilts.length],
                        child: _Sticker(fit: fit, locale: locale),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Sticker extends StatelessWidget {
  const _Sticker({required this.fit, required this.locale});

  final UsageFit fit;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final instead = fit.fits ? null : fit.instead;
    return Semantics(
      container: true,
      label: '${fit.fits ? l10n.fitsYes : l10n.fitsNo}: ${fit.context}',
      excludeSemantics: instead == null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        decoration: BoxDecoration(
          color: fit.fits ? c.primarySoft : null,
          border: fit.fits ? null : Border.all(color: c.line, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s2,
          children: [
            Icon(
              fit.fits ? AppIcons.check : AppIcons.wrong,
              size: 20,
              color: fit.fits ? c.primaryText : c.alert,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      fit.context,
                      locale: locale,
                      style: AppText.bodyLg.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (instead != null)
                    Text(
                      l10n.preferInstead(instead),
                      style: AppText.label.copyWith(
                        color: c.inkSoft,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
