import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/logic/group_controller.dart';
import 'package:tagarela/l10n/l10n.dart';

class SelectionBar extends StatelessWidget {
  const SelectionBar({
    super.key,
    required this.count,
    required this.change,
    required this.onDelete,
    required this.onMove,
  });

  final int count;
  final GroupChange? change;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.s3,
      children: [
        AppButton(
          label: context.l10n.delete,
          leading: const Icon(AppIcons.delete, size: AppIconSize.lg),
          variant: AppButtonVariant.outline,
          size: AppButtonSize.large,
          loading: change == GroupChange.deleting,
          onPressed: count == 0 || change == GroupChange.moving
              ? null
              : onDelete,
        ),
        Expanded(
          child: AppButton(
            label: context.l10n.moveTerms(count),
            size: AppButtonSize.large,
            expand: true,
            loading: change == GroupChange.moving,
            onPressed: count == 0 || change == GroupChange.deleting
                ? null
                : onMove,
          ),
        ),
      ],
    );
  }
}
