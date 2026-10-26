import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class CourseBubble extends StatelessWidget {
  const CourseBubble({
    super.key,
    required this.language,
    this.size = 48,
    this.active = false,
  });

  final CourseLanguage language;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: AppBubble(
        size: size,
        color: active ? c.primary : c.primarySoft,
        foreground: active ? c.onPrimary : c.primaryText,
        child: Text(language.code),
      ),
    );
  }
}
