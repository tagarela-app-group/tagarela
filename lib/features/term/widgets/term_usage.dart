import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermUsage extends StatelessWidget {
  const TermUsage({
    super.key,
    required this.card,
    required this.learning,
    required this.base,
    required this.noteRevealed,
    required this.onNoteReveal,
  });

  static const _tilts = [-0.035, 0.026, -0.017, 0.03];

  final TermCard card;
  final CourseLanguage learning;
  final CourseLanguage base;
  final bool noteRevealed;
  final ValueChanged<bool> onNoteReveal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final formality = card.formality;
    final note = card.formalityNote;
    final inset = note == null ? 0.0 : AppSpacing.s2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s3,
      children: [
        if (formality != null)
          AppCard(
            padding: note == null
                ? const EdgeInsets.all(AppSpacing.s4)
                : const EdgeInsets.fromLTRB(
                    AppSpacing.s4,
                    AppSpacing.s2,
                    AppSpacing.s2,
                    AppSpacing.s4,
                  ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: note == null || noteRevealed
                  ? null
                  : () => onNoteReveal(true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.s3,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(l10n.formality, style: AppText.titleSm),
                        ),
                      ),
                      if (note != null)
                        AppIconButton(
                          icon: noteRevealed ? AppIcons.cover : AppIcons.reveal,
                          tooltip: noteRevealed ? l10n.coverAgain : l10n.reveal,
                          onPressed: () => onNoteReveal(!noteRevealed),
                        ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: inset),
                    child: Row(
                      spacing: 10,
                      children: [
                        DrawnIcon(
                          DrawnGlyph.sandal,
                          size: 26,
                          color: c.inkSoft,
                        ),
                        Expanded(
                          child: SegmentBar(
                            height: 10,
                            semanticLabel: l10n.formalityMeter(
                              l10n.formalityLevel(formality.name),
                              formality.index + 1,
                            ),
                            segments: [
                              for (final level in Formality.values)
                                Segment(
                                  1,
                                  level == formality
                                      ? c.scale[level.index]
                                      : c.scale[level.index].withValues(
                                          alpha: 0.25,
                                        ),
                                ),
                            ],
                          ),
                        ),
                        DrawnIcon(DrawnGlyph.tie, size: 26, color: c.inkSoft),
                      ],
                    ),
                  ),
                  ExcludeSemantics(
                    child: Padding(
                      padding: EdgeInsets.only(left: 36, right: 36 + inset),
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
                                      ? c.scaleText[level.index]
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
                  if (note != null)
                    Padding(
                      padding: EdgeInsets.only(right: inset),
                      child: Obscured(
                        obscured: !noteRevealed,
                        child: MarkedText(
                          note,
                          locale: Locale(base.name),
                          markLocale: Locale(learning.name),
                          style: AppText.bodyMd.copyWith(color: c.inkSoft),
                        ),
                      ),
                    ),
                ],
              ),
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
                        child: _Sticker(
                          fit: fit,
                          locale: Locale(base.name),
                          insteadLocale: Locale(learning.name),
                        ),
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
  const _Sticker({
    required this.fit,
    required this.locale,
    required this.insteadLocale,
  });

  final UsageFit fit;
  final Locale locale;
  final Locale insteadLocale;

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
                    MarkedText(
                      l10n.preferInstead('*$instead*'),
                      locale: locale,
                      markLocale: insteadLocale,
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
