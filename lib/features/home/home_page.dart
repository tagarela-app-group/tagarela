import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/stores/store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/modals/course_modal.dart';
import 'package:tagarela/features/home/widgets/review_card.dart';
import 'package:tagarela/features/home/widgets/vocabulary_summary.dart';
import 'package:tagarela/features/practice/practice_page.dart';
import 'package:tagarela/shared/widgets/user_avatar.dart';
import 'package:tagarela/l10n/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onSeeVocabulary,
    required this.onCapture,
  });

  final VoidCallback onSeeVocabulary;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final stores = <Store>[scope.vocabulary, scope.practice];

    return ListenableBuilder(
      listenable: Listenable.merge([...stores, scope.auth, scope.courses]),
      builder: (context, _) {
        final header = _HomeHeader(
          user: scope.auth.user,
          course: scope.courses.active,
          now: DateTime.now(),
        );
        if (!stores.isReady) {
          return AppPage(
            header: header,
            centerLast: true,
            children: [AsyncStatus(error: stores.error, onRetry: stores.retry)],
          );
        }
        final vocabulary = scope.vocabulary.data!;
        final review = scope.practice.data!;
        if (vocabulary.termCount == 0 && review.due == 0) {
          return AppPage(
            header: header,
            centerLast: true,
            children: [
              StateMessage(
                glyph: const DrawnIcon(DrawnGlyph.bubble),
                title: context.l10n.homeEmptyTitle,
                message: context.l10n.homeEmptyMessage,
                actionLabel: context.l10n.homeFirstCapture,
                actionIcon: AppIcons.add,
                onAction: onCapture,
              ),
            ],
          );
        }
        return AppPage(
          header: header,
          children: [
            VocabularySummary(
              learning: vocabulary.learningCount,
              mastered: vocabulary.masteredCount,
              onSeeAll: onSeeVocabulary,
            ),
            if (review.due > 0)
              ReviewCard(
                count: review.due,
                onStart: review.rounds.isEmpty
                    ? null
                    : () => PracticePage.openReview(context, review.rounds),
              ),
          ],
        );
      },
    );
  }
}

String greeting(AppLocalizations l10n, DateTime now, String name) {
  final period = switch (now.hour) {
    >= 5 && < 12 => 'morning',
    >= 12 && < 18 => 'afternoon',
    _ => 'evening',
  };
  return name.isEmpty ? l10n.greeting(period) : l10n.greetingName(period, name);
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.user,
    required this.course,
    required this.now,
  });

  final User? user;
  final Course? course;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      spacing: AppSpacing.s3,
      children: [
        UserAvatar(user: user),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting(context.l10n, now, user?.firstName ?? ''),
                style: AppText.bodyMd.copyWith(color: c.onHeaderSoft),
              ),
              Text(
                context.l10n.homeTagline,
                style: AppText.titleMd.copyWith(color: AppPalette.white),
              ),
            ],
          ),
        ),
        if (course case final course?)
          HeaderPill(
            onTap: () => CourseModal.show(context),
            semanticLabel: context.l10n.courseBadge(
              context.l10n.coursePair(course.base.name, course.learning.name),
            ),
            padding: const EdgeInsets.only(
              left: AppSpacing.s15,
              right: AppSpacing.s25,
            ),
            child: Row(
              spacing: AppSpacing.s1,
              children: [
                FlagBadge(
                  country: course.learning.country,
                  size: AppBubbleSize.sm,
                  ring: AppPalette.white,
                ),
                const Icon(AppIcons.expand),
              ],
            ),
          ),
      ],
    );
  }
}
