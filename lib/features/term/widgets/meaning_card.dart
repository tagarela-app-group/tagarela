import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class MeaningCard extends StatelessWidget {
  const MeaningCard({
    super.key,
    required this.card,
    required this.learning,
    required this.base,
    required this.revealed,
    required this.flipped,
    required this.onReveal,
    required this.onFlip,
  });

  final TermCard card;
  final CourseLanguage learning;
  final CourseLanguage base;
  final bool revealed;
  final bool flipped;
  final VoidCallback onReveal;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final other = flipped ? learning : base;
    return Stack(
      children: [
        FrostedGlass(
          frosted: !revealed,
          overlay: GlassPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Text(
                  l10n.guessTitle,
                  textAlign: TextAlign.center,
                  style: AppText.titleSm,
                ),
                Text(
                  l10n.guessHint,
                  textAlign: TextAlign.center,
                  style: AppText.label.copyWith(
                    color: context.colors.inkSoft,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                AppButton(
                  label: l10n.revealNow,
                  leading: const Icon(AppIcons.reveal, size: 18),
                  onPressed: onReveal,
                ),
              ],
            ),
          ),
          child: FlipCard(
            flipped: revealed && flipped,
            front: _Side(
              label: l10n.cardSide(learning.name),
              side: card.learning,
              locale: Locale(learning.name),
            ),
            back: _Side(
              label: l10n.cardSide(base.name),
              side: card.base,
              locale: Locale(base.name),
            ),
          ),
        ),
        if (revealed)
          Positioned(
            top: 10,
            right: 10,
            child: Semantics(
              container: true,
              button: true,
              label: l10n.seeIn(other.name),
              onTap: onFlip,
              excludeSemantics: true,
              child: AppButton(
                label: other.code,
                leading: const Icon(AppIcons.language, size: 18),
                variant: AppButtonVariant.tonal,
                size: AppButtonSize.small,
                onPressed: onFlip,
              ),
            ),
          ),
      ],
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.label, required this.side, required this.locale});

  final String label;
  final CardSide side;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppText.overline.copyWith(
                    fontSize: 11,
                    color: c.inkSoft,
                  ),
                ),
                if (side.headline case final headline?)
                  Text(
                    headline,
                    locale: locale,
                    style: AppText.titleMd.copyWith(
                      fontSize: 22,
                      color: c.primaryText,
                    ),
                  ),
              ],
            ),
          ),
          if (side.inContext case final text?)
            _Field(title: l10n.inYourContext, text: text, locale: locale),
          if (side.explanation case final text?)
            _Field(title: l10n.explanation, text: text, locale: locale),
          if (side.pitfall case final pitfall?)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: AppSpacing.s3,
              ),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Icon(AppIcons.warning, size: 18, color: c.alert),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${l10n.pitfallLabel} ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: pitfall),
                        ],
                      ),
                      locale: locale,
                      style: AppText.bodyMd,
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

class _Field extends StatelessWidget {
  const _Field({required this.title, required this.text, required this.locale});

  final String title;
  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s1,
      children: [
        Text(
          title,
          style: AppText.pill.copyWith(color: context.colors.inkSoft),
        ),
        Text(
          text,
          locale: locale,
          style: AppText.bodyLg.copyWith(fontSize: 15, height: 22 / 15),
        ),
      ],
    );
  }
}
