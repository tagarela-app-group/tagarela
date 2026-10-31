import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/modals/base_language_modal.dart';
import 'package:tagarela/features/course/widgets/course_base_card.dart';
import 'package:tagarela/features/course/widgets/course_hello.dart';
import 'package:tagarela/features/course/widgets/course_language_option.dart';
import 'package:tagarela/l10n/l10n.dart';

class CoursePickerPage extends StatefulWidget {
  const CoursePickerPage({super.key, this.closable = false});

  final bool closable;

  static Future<void> open(NavigatorState navigator) => navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => const CoursePickerPage(closable: true),
    ),
  );

  @override
  State<CoursePickerPage> createState() => _CoursePickerPageState();
}

class _CoursePickerPageState extends State<CoursePickerPage> {
  late CourseLanguage _base =
      CourseLanguage.of(Localizations.localeOf(context).languageCode) ??
      CourseLanguage.en;
  CourseLanguage? _learning;
  var _busy = false;

  Future<void> _chooseBase() async {
    final base = await BaseLanguageModal.show(context, _base);
    if (base == null || !mounted) return;
    setState(() {
      _base = base;
      if (_learning == base) _learning = null;
    });
  }

  Future<void> _start(String failed) async {
    final scope = AppScope.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await scope.courses.start(_learning!, _base);
    } on Exception {
      if (!mounted) return;
      setState(() => _busy = false);
      AppToast.notice(context, failed);
      return;
    }
    if (widget.closable) {
      navigator.pop();
      await scope.session.loadStudy();
    } else {
      await scope.session.loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: _base.locale,
      child: Builder(builder: _page),
    );
  }

  Widget _page(BuildContext context) {
    final l10n = context.l10n;
    final learning = _learning;

    return AppPage(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s4,
        children: [
          if (widget.closable)
            AppIconButton(
              icon: AppIcons.close,
              tooltip: l10n.close,
              onPressed: () => Navigator.of(context).pop(),
              variant: AppIconButtonVariant.onHeader,
            ),
          PageHeader(
            title: l10n.coursePickTitle,
            subtitle: l10n.coursePickSubtitle,
          ),
          ExcludeSemantics(
            child: Column(
              spacing: AppSpacing.s2,
              children: [
                CourseHello(label: l10n.courseBaseSection, language: _base),
                CourseHello(
                  label: l10n.courseLearnSection,
                  language: learning,
                  mine: true,
                ),
              ],
            ),
          ),
        ],
      ),
      footer: AppButton(
        label: learning == null
            ? l10n.coursePickLearning
            : l10n.courseStart(learning.name),
        size: AppButtonSize.large,
        expand: true,
        loading: _busy,
        onPressed: learning == null
            ? null
            : () => _start(l10n.courseStartFailed),
      ),
      children: [
        _Section(
          title: l10n.courseBaseSection,
          child: CourseBaseCard(language: _base, onTap: _chooseBase),
        ),
        _Section(
          title: l10n.courseLearnSection,
          child: Column(
            spacing: AppSpacing.s2,
            children: [
              for (final language in CourseLanguage.values)
                if (language != _base)
                  CourseLanguageOption(
                    language: language,
                    selected: language == learning,
                    onTap: () => setState(() => _learning = language),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s3,
      children: [
        Semantics(
          header: true,
          child: Text(
            title.toUpperCase(),
            style: AppText.overline.copyWith(color: context.colors.inkSoft),
          ),
        ),
        child,
      ],
    );
  }
}
