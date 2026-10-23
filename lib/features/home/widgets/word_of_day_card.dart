import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class WordOfDayCard extends StatelessWidget {
  const WordOfDayCard({super.key, required this.word});

  final WordOfDay word;

  static const _padding = AppSpacing.s5;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppPalette.mango,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_padding),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppPalette.ink),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -34 - _padding,
              top: -38 - _padding,
              child: SpeechBubbleIcon(
                size: 150,
                color: AppPalette.ink.withValues(alpha: 0.07),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s3,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('PALAVRA DO DIA', style: AppText.overline),
                    ),
                    Text(
                      word.dateLabel,
                      style: AppText.label.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: AppSpacing.s3,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(word.text, style: AppText.display),
                          Text(
                            '${word.phonetic} · ${word.partOfSpeech}',
                            style: AppText.bodyMd,
                          ),
                        ],
                      ),
                    ),
                    AppIconButton(
                      icon: AppIcons.listen,
                      tooltip: 'Ouvir pronúncia',
                      onPressed: () {},
                      variant: AppIconButtonVariant.ink,
                      size: 48,
                    ),
                  ],
                ),
                Text(
                  word.translation,
                  style: AppText.term.copyWith(fontFamily: AppFonts.body),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: AppSpacing.s3,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.ink.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    '“${word.example}”',
                    style: AppText.bodyLg.copyWith(fontSize: 15),
                  ),
                ),
                AppButton(
                  label: 'Adicionar ao vocabulário',
                  onPressed: () {},
                  leading: const Icon(AppIcons.add, size: 20),
                  variant: AppButtonVariant.ink,
                  expand: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
