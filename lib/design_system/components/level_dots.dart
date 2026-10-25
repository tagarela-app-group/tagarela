import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/l10n/l10n.dart';

class LevelDots extends StatelessWidget {
  const LevelDots({
    super.key,
    required this.level,
    required this.color,
    this.max = 5,
  });

  final int level;
  final Color color;
  final int max;

  @override
  Widget build(BuildContext context) {
    final track = context.colors.surfaceAlt;
    return Semantics(
      label: context.l10n.levelOf(level, max),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          for (var i = 0; i < max; i++)
            Container(
              width: 12,
              height: 4,
              decoration: BoxDecoration(
                color: i < level ? color : track,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
        ],
      ),
    );
  }
}
