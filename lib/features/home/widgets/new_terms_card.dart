import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class NewTermsCard extends StatelessWidget {
  const NewTermsCard({super.key, required this.count, required this.onSee});

  final int count;
  final VoidCallback onSee;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Row(
        spacing: AppSpacing.s35,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.newTerms(count), style: AppText.titleMd),
                Text(
                  l10n.newTermsHint,
                  style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
                ),
              ],
            ),
          ),
          AppButton(
            label: l10n.seeAll,
            variant: AppButtonVariant.tonal,
            onPressed: onSee,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}
