import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/widgets/course_bubble.dart';
import 'package:tagarela/l10n/l10n.dart';

class BaseLanguageModal extends StatelessWidget {
  const BaseLanguageModal({super.key, required this.selected});

  final CourseLanguage selected;

  static Future<CourseLanguage?> show(
    BuildContext context,
    CourseLanguage selected,
  ) => AppModal.show<CourseLanguage>(
    context,
    (modal) => Localizations.override(
      context: modal,
      locale: selected.locale,
      child: BaseLanguageModal(selected: selected),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppModal(
      title: l10n.courseBaseSection,
      subtitle: l10n.courseBaseModalSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s2,
        children: [
          for (final language in CourseLanguage.values)
            if (AppLocalizations.supportedLocales.contains(language.locale))
              OptionRow(
                leading: CourseBubble(language: language, size: 40),
                title: language.nativeName,
                subtitle: language == selected
                    ? l10n.courseBaseHint
                    : l10n.courseLanguage(language.name),
                selected: language == selected,
                onTap: () => Navigator.pop(context, language),
              ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s2),
            child: Text(
              l10n.courseBaseMore,
              textAlign: TextAlign.center,
              style: AppText.label.copyWith(
                color: context.colors.inkSoft,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
