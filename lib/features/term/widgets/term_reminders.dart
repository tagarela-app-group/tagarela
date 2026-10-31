import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/widgets/got_it_check.dart';
import 'package:tagarela/features/term/widgets/term_pitfall.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermReminders extends StatelessWidget {
  const TermReminders({
    super.key,
    required this.card,
    required this.learning,
    required this.base,
    required this.revealed,
    required this.asked,
    required this.bursts,
    required this.onReveal,
    required this.pitfallRevealed,
    required this.pitfallBursts,
    required this.onPitfallReveal,
  });

  final TermCard card;
  final CourseLanguage learning;
  final CourseLanguage base;
  final bool revealed;
  final bool asked;
  final int bursts;
  final VoidCallback onReveal;
  final bool pitfallRevealed;
  final int pitfallBursts;
  final ValueChanged<bool> onPitfallReveal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final learningLocale = Locale(learning.name);
    final baseLocale = Locale(base.name);
    final literal = card.base.literal;
    final meaning = card.base.headline;
    final imagine = card.base.imagine;
    final mistake = card.mistake;
    final pitfall = card.base.pitfall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s25,
      children: [
        if (card.hasReveal || imagine != null)
          Stack(
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.s45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.s3,
                  children: [
                    if (card.hasReveal)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: revealed ? null : onReveal,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            spacing: AppSpacing.s3,
                            children: [
                              if (literal != null)
                                Expanded(
                                  child: _Labeled(
                                    label: l10n.literally,
                                    text: literal,
                                    locale: baseLocale,
                                    obscured: !revealed,
                                    style: AppText.titleLg.copyWith(
                                      color: c.ink,
                                    ),
                                  ),
                                ),
                              if (literal != null && meaning != null)
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: c.line,
                                ),
                              if (meaning != null)
                                Expanded(
                                  child: _Labeled(
                                    label: l10n.itMeans,
                                    text: meaning,
                                    locale: baseLocale,
                                    obscured: !revealed,
                                    style: AppText.titleMd.copyWith(
                                      color: c.primaryText,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (imagine != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s35,
                          vertical: AppSpacing.s3,
                        ),
                        decoration: BoxDecoration(
                          color: c.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppSpacing.s25,
                          children: [
                            Icon(
                              AppIcons.reveal,
                              size: AppIconSize.lg,
                              color: c.primaryText,
                            ),
                            Expanded(
                              child: MarkedText(
                                imagine,
                                lead: l10n.imagine,
                                locale: baseLocale,
                                markLocale: learningLocale,
                                style: AppText.bodyLg.copyWith(
                                  fontSize: AppFontSize.body,
                                  height: 22 / 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (bursts > 0)
                Positioned.fill(child: BubbleBurst(key: ValueKey(bursts))),
            ],
          ),
        if (asked) const GotItCheck(),
        if (mistake != null || pitfall != null)
          TermPitfall(
            mistake: mistake,
            pitfall: pitfall,
            learning: learning,
            base: base,
            revealed: pitfallRevealed,
            bursts: pitfallBursts,
            onReveal: onPitfallReveal,
          ),
      ],
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({
    required this.label,
    required this.text,
    required this.locale,
    required this.obscured,
    required this.style,
  });

  final String label;
  final String text;
  final Locale locale;
  final bool obscured;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: AppSpacing.s05,
      children: [
        Text(
          label.toUpperCase(),
          style: AppText.overline.copyWith(
            fontSize: AppFontSize.caption,
            color: context.colors.inkSoft,
          ),
        ),
        Obscured(
          obscured: obscured,
          child: Text(text, locale: locale, style: style),
        ),
      ],
    );
  }
}
