import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.count, required this.onStart});

  final int count;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        spacing: AppSpacing.s35,
        children: [
          const IconTile(
            icon: AppIcons.review,
            accent: AppAccent.violet,
            size: AppBubbleSize.lg,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.reviewToday,
                  style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  context.l10n.termsWaiting(count),
                  style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
                ),
              ],
            ),
          ),
          AppButton(
            label: context.l10n.start,
            onPressed: onStart,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}
