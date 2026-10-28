import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class ObscuredNote extends StatelessWidget {
  const ObscuredNote(
    this.text, {
    super.key,
    required this.obscured,
    required this.base,
    required this.learning,
  });

  final String text;
  final bool obscured;
  final CourseLanguage base;
  final CourseLanguage learning;

  @override
  Widget build(BuildContext context) {
    return Obscured(
      obscured: obscured,
      child: MarkedText(
        text,
        locale: Locale(base.name),
        markLocale: Locale(learning.name),
        style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
      ),
    );
  }
}
