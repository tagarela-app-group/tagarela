import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.count, required this.onStart});

  final int count;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        spacing: 14,
        children: [
          const IconTile(
            icon: AppIcons.review,
            accent: AppAccent.violet,
            size: 48,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisão de hoje',
                  style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$count termos esperando',
                  style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
                ),
              ],
            ),
          ),
          AppButton(
            label: 'Começar',
            onPressed: onStart,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}
