import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class CourseBubble extends StatelessWidget {
  const CourseBubble({
    super.key,
    required this.language,
    this.size = 48,
    this.selected,
  });

  final CourseLanguage language;
  final double size;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (color, foreground) = switch (selected) {
      null => (c.surfaceAlt, c.ink),
      true => (c.primary, c.onPrimary),
      false => (c.primarySoft, c.primaryText),
    };
    return ExcludeSemantics(
      child: AppBubble(
        size: size,
        color: color,
        foreground: foreground,
        badge: FlagBadge(
          country: language.country,
          size: size / 2,
          ring: c.surface,
        ),
        child: Text(language.code),
      ),
    );
  }
}
