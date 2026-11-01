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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.reviewToday,
                  style: AppText.label.copyWith(
                    color: context.colors.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(context.l10n.termCount(count), style: AppText.titleMd),
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
