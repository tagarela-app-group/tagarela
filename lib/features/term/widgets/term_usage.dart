import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermUsage extends StatelessWidget {
  const TermUsage({super.key, required this.card});

  final TermCard card;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final formality = card.formality;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s3,
      children: [
        if (formality != null)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.formality,
                        style: AppText.label.copyWith(color: c.inkSoft),
                      ),
                    ),
                    Text(
                      l10n.formalityLevel(formality.name),
                      style: AppText.label.copyWith(color: c.primaryText),
                    ),
                  ],
                ),
                SegmentBar(
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
                ExcludeSemantics(
                  child: Row(
                    spacing: AppSpacing.s1,
                    children: [
                      for (final level in Formality.values)
                        Expanded(
                          child: Text(
                            l10n.formalityLevel(level.name),
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
                if (card.formalityNote case final note?)
                  Text(note, style: AppText.bodyMd.copyWith(color: c.inkSoft)),
              ],
            ),
          ),
        if (card.fits.isNotEmpty)
          AppCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s4,
              AppSpacing.s4,
              AppSpacing.s4,
              AppSpacing.s1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.whereItFits,
                    style: AppText.label.copyWith(color: c.inkSoft),
                  ),
                ),
                for (final (i, fit) in card.fits.indexed) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: c.line),
                  _Fit(fit: fit),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Fit extends StatelessWidget {
  const _Fit({required this.fit});

  final UsageFit fit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
      child: Row(
        spacing: AppSpacing.s3,
        children: [
          Icon(
            fit.fits ? AppIcons.fits : AppIcons.doesNotFit,
            size: 22,
            color: fit.fits ? c.primaryText : c.inkSoft,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fit.context,
                  style: AppText.bodyLg.copyWith(fontSize: 15, height: 21 / 15),
                ),
                if (fit.instead case final word? when !fit.fits)
                  Text(
                    context.l10n.preferInstead(word),
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
    );
  }
}
