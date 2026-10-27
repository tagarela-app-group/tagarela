import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class RoundResult extends StatelessWidget {
  const RoundResult({
    super.key,
    required this.exercise,
    required this.outcome,
    required this.learning,
    required this.base,
    required this.voice,
    required this.last,
    required this.onNext,
  });

  final Exercise exercise;
  final Outcome outcome;
  final CourseLanguage learning;
  final CourseLanguage base;
  final Voice voice;
  final bool last;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final (icon, bg, fg) = switch (outcome) {
      Outcome.first ||
      Outcome.retry => (AppIcons.check, c.primary, c.onPrimary),
      Outcome.hint => (AppIcons.idea, c.learningSoft, c.learningText),
      Outcome.missed => (AppIcons.reveal, c.surfaceAlt, c.alert),
    };
    final say = exercise.extra.say;
    return BottomPanel(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.s5,
        AppSpacing.screen,
        AppSpacing.s4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          Semantics(
            liveRegion: true,
            child: Row(
              spacing: 10,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, size: 20, color: fg),
                ),
                Expanded(
                  child: Text(
                    l10n.outcomeTitle(outcome.name),
                    style: AppText.titleMd.copyWith(color: c.ink),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s1,
            children: [
              Text(
                l10n.means.toUpperCase(),
                style: AppText.overline.copyWith(color: c.inkSoft),
              ),
              Text(
                exercise.translation,
                locale: Locale(base.name),
                style: AppText.bodyLg.copyWith(color: c.ink),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s4,
              AppSpacing.s3,
              AppSpacing.s2,
              AppSpacing.s3,
            ),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: AppRadius.bubble(AppRadius.lg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s2,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.s1,
                    children: [
                      Text(
                        l10n.takeAway.toUpperCase(),
                        style: AppText.overline.copyWith(color: c.primaryText),
                      ),
                      MarkedText(
                        exercise.extra.note,
                        style: AppText.bodyLg.copyWith(color: c.ink),
                        locale: Locale(base.name),
                        markLocale: Locale(learning.name),
                      ),
                    ],
                  ),
                ),
                if (say.isNotEmpty)
                  ListenableBuilder(
                    listenable: voice,
                    builder: (context, _) {
                      final saying =
                          voice.speaking != null && voice.text == say;
                      return AppIconButton(
                        icon: saying ? AppIcons.stop : AppIcons.listen,
                        tooltip: saying ? l10n.stop : l10n.listenExtra,
                        variant: AppIconButtonVariant.soft,
                        onPressed: () =>
                            saying ? voice.stop() : voice.speak(say, learning),
                      );
                    },
                  ),
              ],
            ),
          ),
          AppButton(
            label: last ? l10n.seeSummary : l10n.nextRound,
            expand: true,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
