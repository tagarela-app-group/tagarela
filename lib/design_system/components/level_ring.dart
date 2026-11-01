import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';
import 'package:tagarela/l10n/l10n.dart';

class LevelRing extends StatelessWidget {
  const LevelRing({
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
    final c = context.colors;
    return Semantics(
      label: context.l10n.levelOf(level, max),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: AppBubbleSize.md,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: level / max,
              color: color,
              backgroundColor: c.line,
              strokeWidth: AppSpacing.s1,
              strokeAlign: CircularProgressIndicator.strokeAlignInside,
            ),
            Center(
              child: Text(
                '$level',
                style: AppText.label.copyWith(color: c.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
