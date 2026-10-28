import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/group_style.dart';

class TermTopBar extends StatelessWidget {
  const TermTopBar({super.key, required this.group});

  final TermGroup? group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppIconButton(
          icon: AppIcons.back,
          tooltip: l10n.back,
          onPressed: () => Navigator.of(context).pop(),
          variant: AppIconButtonVariant.onHeader,
        ),
        Flexible(
          child: HeaderPill(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(group?.glyph ?? AppIcons.ungrouped, size: 14),
                Flexible(
                  child: Text(
                    group?.name ?? l10n.ungrouped,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
