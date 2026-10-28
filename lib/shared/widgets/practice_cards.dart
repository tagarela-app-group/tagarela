import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/exercise_style.dart';

class PracticeCards extends StatelessWidget {
  const PracticeCards({super.key, required this.onOpen});

  final ValueChanged<ExerciseKind> onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s2,
      children: [
        for (final kind in ExerciseKind.values)
          AppCard(
            onTap: () => onOpen(kind),
            child: Row(
              spacing: 14,
              children: [
                IconTile(icon: kind.glyph, accent: AppAccent.violet),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        l10n.exerciseKind(kind.name),
                        style: AppText.titleSm.copyWith(color: c.ink),
                      ),
                      Text(
                        l10n.exerciseKindHint(kind.name),
                        style: AppText.bodyMd.copyWith(color: c.inkSoft),
                      ),
                    ],
                  ),
                ),
                Icon(AppIcons.forward, color: c.inkSoft),
              ],
            ),
          ),
      ],
    );
  }
}
