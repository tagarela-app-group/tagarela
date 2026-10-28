import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

enum StatusTone {
  learning,
  mastered,
  primary,
  neutral,
  alert;

  (Color, Color) colors(AppColors c) => switch (this) {
    learning => (c.learningSoft, c.learningText),
    mastered => (c.masteredSoft, c.masteredText),
    primary => (c.primarySoft, c.primaryText),
    neutral => (c.surfaceAlt, c.inkSoft),
    alert => (c.accent(AppAccent.coral).soft, c.accent(AppAccent.coral).fg),
  };
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = tone.colors(context.colors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppText.pill.copyWith(color: fg)),
    );
  }
}
