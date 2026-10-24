import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/widgets/review_card.dart';
import 'package:tagarela/features/home/widgets/vocabulary_summary.dart';
import 'package:tagarela/features/home/widgets/word_of_day_card.dart';
import 'package:tagarela/features/profile/user_avatar.dart';

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
    final stores = <Store>[scope.home, scope.vocabulary];

    return ListenableBuilder(
      listenable: Listenable.merge([...stores, scope.auth]),
      builder: (context, _) {
        final header = _HomeHeader(user: scope.auth.user, now: DateTime.now());
        if (!stores.isReady) {
          return SheetPage(
            header: header,
            centerLast: true,
            children: [AsyncStatus(error: stores.error, onRetry: stores.retry)],
          );
        }
        final home = scope.home.data!;
        final groups = scope.vocabulary.data!;
        if (groups.termCount == 0 &&
            home.wordOfDay == null &&
            home.stats.reviewCount == 0) {
          return SheetPage(
            header: header,
            centerLast: true,
            children: [
              StateMessage(
                glyph: const SpeechBubbleIcon(),
                title: 'Seu inglês começa aqui',
                message:
                    'Capture o que você ouviu ou leu hoje, por foto, áudio ou '
                    'texto. Os termos que você confirmar aparecem aqui.',
                actionLabel: 'Fazer a primeira captura',
                actionIcon: AppIcons.add,
                onAction: onCapture,
              ),
            ],
          );
        }
        return SheetPage(
          header: header,
          children: [
            if (home.wordOfDay case final word?) WordOfDayCard(word: word),
            VocabularySummary(
              learning: groups.learningCount,
              mastered: groups.masteredCount,
              weekGain: home.stats.weekGain,
              onSeeAll: onSeeVocabulary,
            ),
            if (home.stats.reviewCount > 0)
              ReviewCard(count: home.stats.reviewCount, onStart: () {}),
          ],
        );
      },
    );
  }
}

String greeting(DateTime now, String name) {
  final period = switch (now.hour) {
    >= 5 && < 12 => 'Bom dia',
    >= 12 && < 18 => 'Boa tarde',
    _ => 'Boa noite',
  };
  return name.isEmpty ? '$period!' : '$period, $name';
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.user, required this.now});

  final User? user;
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
                greeting(now, user?.firstName ?? ''),
                style: AppText.bodyMd.copyWith(color: c.onHeaderSoft),
              ),
              Text(
                'Vamos tagarelar?',
                style: AppText.titleMd.copyWith(color: AppPalette.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
