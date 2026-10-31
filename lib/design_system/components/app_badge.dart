import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

enum AppBadgeTone { alert, primary }

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, required this.tone});

  final String label;
  final AppBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      AppBadgeTone.alert => (c.alert, c.onAlert),
      AppBadgeTone.primary => (c.primary, c.onPrimary),
    };
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.surface, width: 2),
      ),
      child: Text(
        label,
        textScaler: TextScaler.noScaling,
        style: AppText.tag.copyWith(
          letterSpacing: 0,
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
          color: fg,
        ),
      ),
    );
  }
}
