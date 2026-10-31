import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/logic/practice_session.dart';
import 'package:tagarela/l10n/l10n.dart';

class PracticeSummary extends StatelessWidget {
  const PracticeSummary({
    super.key,
    required this.results,
    required this.review,
    required this.language,
    required this.onFinish,
  });

  final List<PracticeResult> results;
  final bool review;
  final CourseLanguage language;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final firsts = results.where((r) => r.outcome == Outcome.first).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.s6,
            AppSpacing.screen,
            AppSpacing.s8,
          ),
          child: Column(
            spacing: AppSpacing.s1,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.only(bottom: AppSpacing.s2),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: AppRadius.bubble(AppRadius.xl),
                    ),
                    child: Icon(
                      AppIcons.check,
                      size: AppIconSize.xxl,
                      color: c.primary,
                    ),
                  ),
                  const Positioned.fill(child: BubbleBurst()),
                ],
              ),
              Text(
                review ? l10n.reviewDone : l10n.practiceDone,
                textAlign: TextAlign.center,
                style: AppText.display.copyWith(color: AppPalette.white),
              ),
              Text(
                l10n.firstTries(firsts, results.length),
                textAlign: TextAlign.center,
                style: AppText.bodyLg.copyWith(color: c.onHeaderSoft),
              ),
            ],
          ),
        ),
        Expanded(
          child: BottomPanel(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.s6,
              AppSpacing.screen,
              AppSpacing.s4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s3,
              children: [
                SectionLabel(label: l10n.takenAway),
                Expanded(
                  child: ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) => Divider(color: c.line),
                    itemBuilder: (context, i) => _row(context, results[i]),
                  ),
                ),
                if (!review)
                  Text(
                    l10n.practiceFree,
                    style: AppText.bodyMd.copyWith(color: c.inkSoft),
                  ),
                AppButton(
                  label: l10n.finish,
                  expand: true,
                  onPressed: onFinish,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, PracticeResult result) {
    final c = context.colors;
    final locale = Locale(language.name);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
      child: Row(
        spacing: AppSpacing.s3,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s05,
              children: [
                Text(
                  result.term.text,
                  locale: locale,
                  style: AppText.term.copyWith(color: c.ink),
                ),
                if (result.exercise.extra.say.isNotEmpty)
                  Text(
                    '+ ${result.exercise.extra.say}',
                    locale: locale,
                    style: AppText.label.copyWith(color: c.primaryText),
                  ),
              ],
            ),
          ),
          StatusPill(
            label: context.l10n.outcomeLabel(result.outcome.name),
            tone: switch (result.outcome) {
              Outcome.first || Outcome.retry => StatusTone.primary,
              Outcome.hint => StatusTone.learning,
              Outcome.missed => StatusTone.alert,
            },
          ),
        ],
      ),
    );
  }
}
