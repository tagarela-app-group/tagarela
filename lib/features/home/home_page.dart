import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/widgets/review_card.dart';
import 'package:tagarela/features/home/widgets/vocabulary_summary.dart';
import 'package:tagarela/features/home/widgets/word_of_day_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onSeeVocabulary});

  final VoidCallback onSeeVocabulary;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final stores = <Store>[scope.user, scope.home, scope.vocabulary];

    return ListenableBuilder(
      listenable: Listenable.merge(stores),
      builder: (context, _) {
        if (!stores.isReady) {
          return SheetPage(
            header: const PageHeader(title: 'Vamos tagarelar?'),
            children: [AsyncStatus(error: stores.error, onRetry: stores.retry)],
          );
        }
        final home = scope.home.data!;
        final groups = scope.vocabulary.data!;
        return SheetPage(
          header: _HomeHeader(user: scope.user.data!),
          children: [
            WordOfDayCard(word: home.wordOfDay),
            VocabularySummary(
              learning: groups.learningCount,
              mastered: groups.masteredCount,
              weekGain: home.stats.weekGain,
              onSeeAll: onSeeVocabulary,
            ),
            ReviewCard(count: home.stats.reviewCount, onStart: () {}),
          ],
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      spacing: AppSpacing.s3,
      children: [
        AppBubble(child: Text(user.initials)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bom dia, ${user.name}',
                style: AppText.bodyMd.copyWith(color: c.onHeaderSoft),
              ),
              Text(
                'Vamos tagarelar?',
                style: AppText.titleMd.copyWith(color: AppPalette.white),
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Sequência de ${user.streakDays} dias',
          excludeSemantics: true,
          child: Container(
            height: 40,
            padding: const EdgeInsets.only(left: 10, right: 14),
            decoration: BoxDecoration(
              color: c.headerChip,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              spacing: 6,
              children: [
                const Icon(AppIcons.streak, size: 20, color: AppPalette.mango),
                Text(
                  '${user.streakDays}',
                  style: AppText.button.copyWith(color: AppPalette.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
