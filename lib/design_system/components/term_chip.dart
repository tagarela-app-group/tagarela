import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class TermChip extends StatelessWidget {
  const TermChip({
    super.key,
    required this.label,
    this.onRemove,
    this.muted = false,
  });

  final String label;
  final VoidCallback? onRemove;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = muted ? c.inkSoft : c.primaryText;
    final remove = onRemove;
    return Container(
      height: remove == null ? 30 : 40,
      padding: EdgeInsets.only(
        left: AppSpacing.s3,
        right: remove == null ? AppSpacing.s3 : AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        color: muted ? c.surfaceAlt : c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (remove == null ? AppText.label : AppText.button).copyWith(
                color: fg,
              ),
            ),
          ),
          if (remove != null)
            IconButton(
              onPressed: remove,
              tooltip: 'Remover $label',
              icon: const Icon(AppIcons.close),
              iconSize: 16,
              color: fg,
              style: IconButton.styleFrom(
                fixedSize: const Size.square(36),
                minimumSize: const Size.square(36),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }
}
