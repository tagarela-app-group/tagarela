import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermReminders extends StatelessWidget {
  const TermReminders({
    super.key,
    required this.card,
    required this.learning,
    required this.base,
  });

  final TermCard card;
  final CourseLanguage learning;
  final CourseLanguage base;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final baseLocale = Locale(base.name);
    final literal = card.base.literal;
    final imagine = card.base.imagine;
    final meaning = card.base.headline;
    final mistake = card.mistake;
    final pitfall = card.base.pitfall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.remember.toUpperCase(),
            style: AppText.overline.copyWith(color: c.inkSoft),
          ),
        ),
        if (literal != null || imagine != null)
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s3,
              children: [
                if (literal != null)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: AppSpacing.s3,
                      children: [
                        Expanded(
                          child: _Labeled(
                            label: l10n.literally,
                            text: literal,
                            locale: baseLocale,
                            style: AppText.titleLg.copyWith(color: c.ink),
                          ),
                        ),
                        if (meaning != null) ...[
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: c.line,
                          ),
                          Expanded(
                            child: _Labeled(
                              label: l10n.itMeans,
                              text: meaning,
                              locale: baseLocale,
                              style: AppText.titleMd.copyWith(
                                color: c.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (imagine != null)
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
                        Icon(AppIcons.reveal, size: 20, color: c.primaryText),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${l10n.imagine} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: imagine),
                              ],
                            ),
                            locale: baseLocale,
                            style: AppText.bodyLg.copyWith(
                              fontSize: 15,
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
        if (mistake != null || pitfall != null)
          AppCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s4,
              AppSpacing.s4,
              AppSpacing.s4,
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s3,
              children: [
                Row(
                  spacing: AppSpacing.s2,
                  children: [
                    Icon(AppIcons.warning, size: 18, color: c.alert),
                    Text(l10n.pitfallTitle, style: AppText.titleSm),
                  ],
                ),
                if (mistake != null)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.s2,
                      children: [
                        Expanded(
                          child: _Say(
                            label: l10n.sayNot,
                            text: mistake.wrong,
                            locale: Locale(learning.name),
                            wrong: true,
                          ),
                        ),
                        Expanded(
                          child: _Say(
                            label: l10n.say,
                            text: mistake.right,
                            locale: Locale(learning.name),
                            wrong: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (pitfall != null)
                  Text(
                    pitfall,
                    locale: baseLocale,
                    style: AppText.bodyMd.copyWith(color: c.inkSoft),
                  ),
              ],
            ),
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
    required this.style,
  });

  final String label;
  final String text;
  final Locale locale;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 2,
      children: [
        Text(
          label.toUpperCase(),
          style: AppText.overline.copyWith(
            fontSize: 11,
            color: context.colors.inkSoft,
          ),
        ),
        Text(text, locale: locale, style: style),
      ],
    );
  }
}

class _Say extends StatelessWidget {
  const _Say({
    required this.label,
    required this.text,
    required this.locale,
    required this.wrong,
  });

  final String label;
  final String text;
  final Locale locale;
  final bool wrong;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = wrong ? c.alert : c.primaryText;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: wrong ? c.surfaceAlt : c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(
            spacing: 6,
            children: [
              Icon(
                wrong ? AppIcons.wrong : AppIcons.check,
                size: 16,
                color: tone,
              ),
              Text(label, style: AppText.pill.copyWith(color: tone)),
            ],
          ),
          Text(
            text,
            locale: locale,
            style: AppText.bodyLg.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: wrong ? c.inkSoft : c.primaryText,
              decoration: wrong ? TextDecoration.lineThrough : null,
              decorationColor: c.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
