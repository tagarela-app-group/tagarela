import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/widgets/course_bubble.dart';
import 'package:tagarela/l10n/l10n.dart';

class CourseLanguageOption extends StatelessWidget {
  const CourseLanguageOption({
    super.key,
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final CourseLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      child: AppCard(
        selected: selected,
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.s3),
        child: Row(
          spacing: AppSpacing.s3,
          children: [
            CourseBubble(language: language, selected: selected),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    l10n.courseLanguage(language.name),
                    style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    language.hasAudio
                        ? l10n.courseOptionAudio(language.nativeName)
                        : l10n.courseOptionNoAudio(language.nativeName),
                    style: AppText.label.copyWith(
                      color: context.colors.inkSoft,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            AppCheckbox(checked: selected, round: true),
          ],
        ),
      ),
    );
  }
}
