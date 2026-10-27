import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermPitfall extends StatelessWidget {
  const TermPitfall({
    super.key,
    required this.mistake,
    required this.pitfall,
    required this.learning,
    required this.base,
    required this.revealed,
    required this.bursts,
    required this.onReveal,
  });

  final CardMistake? mistake;
  final String? pitfall;
  final CourseLanguage learning;
  final CourseLanguage base;
  final bool revealed;
  final int bursts;
  final ValueChanged<bool> onReveal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final mistake = this.mistake;
    final pitfall = this.pitfall;
    return Stack(
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s4,
            AppSpacing.s2,
            AppSpacing.s2,
            18,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: revealed ? null : () => onReveal(true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s3,
              children: [
                Row(
                  spacing: AppSpacing.s2,
                  children: [
                    Icon(AppIcons.warning, size: 18, color: c.alert),
                    Expanded(
                      child: Text(l10n.pitfallTitle, style: AppText.titleSm),
                    ),
                    AppIconButton(
                      icon: revealed ? AppIcons.cover : AppIcons.reveal,
                      tooltip: revealed ? l10n.coverAgain : l10n.reveal,
                      onPressed: () => onReveal(!revealed),
                    ),
                  ],
                ),
                if (mistake != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s2),
                    child: IntrinsicHeight(
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
                              obscured: !revealed,
                            ),
                          ),
                          Expanded(
                            child: _Say(
                              label: l10n.say,
                              text: mistake.right,
                              locale: Locale(learning.name),
                              wrong: false,
                              obscured: !revealed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (pitfall != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s2),
                    child: Obscured(
                      obscured: !revealed,
                      child: MarkedText(
                        pitfall,
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
        if (bursts > 0)
          Positioned.fill(child: BubbleBurst(key: ValueKey(bursts))),
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
    required this.obscured,
  });

  final String label;
  final String text;
  final Locale locale;
  final bool wrong;
  final bool obscured;

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
          Obscured(
            obscured: obscured,
            child: Text(
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
          ),
        ],
      ),
    );
  }
}
