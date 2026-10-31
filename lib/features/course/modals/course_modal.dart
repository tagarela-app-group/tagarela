import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/course_picker_page.dart';
import 'package:tagarela/l10n/l10n.dart';

class CourseModal extends StatefulWidget {
  const CourseModal({super.key});

  static Future<void> show(BuildContext context) =>
      AppModal.show<void>(context, (_) => const CourseModal());

  @override
  State<CourseModal> createState() => _CourseModalState();
}

class _CourseModalState extends State<CourseModal> {
  String? _switching;

  Future<void> _pick(Course course) async {
    final navigator = Navigator.of(context);
    if (course.active) {
      navigator.pop();
      return;
    }
    final scope = AppScope.of(context);
    final failed = context.l10n.courseSwitchFailed;
    setState(() => _switching = course.id);
    try {
      await scope.courses.activate(course);
    } on Exception {
      if (!mounted) return;
      setState(() => _switching = null);
      AppToast.notice(context, failed);
      return;
    }
    navigator.pop();
    await scope.session.loadStudy();
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
    final app = Localizations.localeOf(context).languageCode;

    return AppModal(
      title: l10n.coursesTitle,
      subtitle: l10n.coursesSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s2,
        children: [
          for (final course in courses)
            OptionRow(
              leading: FlagPair(
                back: course.base.country,
                front: course.learning.country,
              ),
              title: l10n.coursePair(course.base.name, course.learning.name),
              subtitle: [
                l10n.termCount(course.terms),
                if (course.base.name != app)
                  l10n.courseAppIn(course.base.nativeName),
              ].join(' · '),
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
