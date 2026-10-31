import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/widgets/course_bubble.dart';
import 'package:tagarela/l10n/l10n.dart';

class CourseBaseCard extends StatelessWidget {
  const CourseBaseCard({
    super.key,
    required this.language,
    required this.onTap,
  });

  final CourseLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.s3),
      child: Row(
        spacing: AppSpacing.s3,
        children: [
          CourseBubble(language: language),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s05,
              children: [
                Text(
                  language.nativeName,
                  style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  context.l10n.courseBaseHint,
                  style: AppText.label.copyWith(
                    color: c.inkSoft,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            context.l10n.courseBaseChange,
            style: AppText.bodyMd.copyWith(
              color: c.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
