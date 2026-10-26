import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/course_picker_page.dart';
import 'package:tagarela/features/course/widgets/course_bubble.dart';
import 'package:tagarela/l10n/l10n.dart';

class CourseSheet extends StatefulWidget {
  const CourseSheet({super.key});

  static Future<void> show(BuildContext context) =>
      AppSheet.show<void>(context, (_) => const CourseSheet());

  @override
  State<CourseSheet> createState() => _CourseSheetState();
}

class _CourseSheetState extends State<CourseSheet> {
  String? _switching;

  Future<void> _pick(Course course) async {
    final navigator = Navigator.of(context);
    if (course.active) {
      navigator.pop();
      return;
    }
    final scope = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.courseSwitchFailed;
    setState(() => _switching = course.id);
    try {
      await scope.courses.activate(course);
    } on Exception {
      if (!mounted) return;
      setState(() => _switching = null);
      messenger.showSnackBar(SnackBar(content: Text(failed)));
      return;
    }
    navigator.pop();
    await scope.loadStudy();
  }

  void _add() {
    final root = Navigator.of(context, rootNavigator: true);
    Navigator.of(context).pop();
    CoursePickerPage.open(root);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final courses = AppScope.of(context).courses.data ?? const <Course>[];

    return AppSheet(
      icon: AppIcons.language,
      accent: AppAccent.sky,
      title: l10n.coursesTitle,
      subtitle: l10n.coursesSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s2,
        children: [
          for (final course in courses)
            OptionRow(
              leading: CourseBubble(
                language: course.learning,
                active: course.active,
              ),
              title: l10n.courseLanguage(course.learning.name),
              subtitle: [
                l10n.courseVia(course.base.name, course.terms),
                if (!course.learning.hasAudio) l10n.courseNoAudio,
              ].join('\n'),
              selected: course.active,
              trailing: _switching == course.id
                  ? SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: context.colors.primary,
                        semanticsLabel: l10n.loading,
                      ),
                    )
                  : null,
              onTap: _switching == null ? () => _pick(course) : null,
            ),
          const SizedBox(height: AppSpacing.s2),
          AppButton(
            label: l10n.courseAdd,
            leading: const Icon(AppIcons.add),
            variant: AppButtonVariant.tonal,
            expand: true,
            onPressed: _switching == null ? _add : null,
          ),
        ],
      ),
    );
  }
}
