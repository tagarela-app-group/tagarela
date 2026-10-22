import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

enum StatusTone { learning, mastered, primary, neutral }

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      StatusTone.learning => (c.learningSoft, c.learningText),
      StatusTone.mastered => (c.masteredSoft, c.masteredText),
      StatusTone.primary => (c.primarySoft, c.primaryText),
      StatusTone.neutral => (c.surfaceAlt, c.inkSoft),
    };

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
