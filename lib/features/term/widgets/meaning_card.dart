import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class MeaningCard extends StatelessWidget {
  const MeaningCard({
    super.key,
    required this.card,
    required this.learning,
    required this.base,
    required this.flipped,
    required this.onFlip,
  });

  final TermCard card;
  final CourseLanguage learning;
  final CourseLanguage base;
  final bool flipped;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final other = flipped ? learning : base;
    return Stack(
      children: [
        FlipCard(
          flipped: flipped,
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
              leading: const Icon(AppIcons.language, size: AppIconSize.md),
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
      padding: const EdgeInsets.all(AppSpacing.s45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s05,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppText.overline.copyWith(
                    fontSize: AppFontSize.caption,
                    color: c.inkSoft,
                  ),
                ),
                if (side.headline case final headline?)
                  Text(
                    headline,
                    locale: locale,
                    style: AppText.titleMd.copyWith(
                      fontSize: AppFontSize.title,
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
          style: AppText.bodyLg.copyWith(
            fontSize: AppFontSize.body,
            height: 22 / 15,
          ),
        ),
      ],
    );
  }
}
