import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/review_time.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    required this.now,
    required this.onStart,
    required this.onAskForMore,
  });

  static const _secondsPerRound = 40;

  final ReviewSession review;
  final DateTime now;
  final VoidCallback? onStart;
  final VoidCallback onAskForMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final due = review.due;
    final (title, detail) = switch (review) {
      ReviewSession(due: > 0, done: > 0) => (
        l10n.reviewProgress(review.done, review.done + due),
        _minutes(l10n),
      ),
      ReviewSession(due: > 0) => (l10n.termCount(due), _minutes(l10n)),
      ReviewSession(waiting: > 0) => (
        l10n.reviewEnough,
        l10n.reviewWaiting(review.waiting),
      ),
      _ => (
        l10n.reviewAllDone,
        switch (review.nextDueAt) {
          final next? => nextReviewIn(l10n, next, now),
          null => null,
        },
      ),
    };
    return AppCard(
      child: Row(
        spacing: AppSpacing.s35,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reviewToday,
                  style: AppText.label.copyWith(
                    color: context.colors.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(title, style: AppText.titleMd),
                if (detail != null)
                  Text(
                    detail,
                    style: AppText.bodyMd.copyWith(
                      color: context.colors.inkSoft,
                    ),
                  ),
              ],
            ),
          ),
          if (due > 0)
            AppButton(
              label: l10n.start,
              onPressed: onStart,
              size: AppButtonSize.small,
            )
          else if (review.waiting > 0)
            AppButton(
              label: l10n.reviewAskMore,
              variant: AppButtonVariant.tonal,
              onPressed: onAskForMore,
              size: AppButtonSize.small,
            ),
        ],
      ),
    );
  }

  String _minutes(AppLocalizations l10n) {
    final seconds = review.due * _secondsPerRound;
    return l10n.reviewMinutes((seconds / 60).ceil());
  }
}
