import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/widgets/course_bubble.dart';
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
  CourseLanguage? _learning;
  late CourseLanguage? _base = CourseLanguage.values.byName(
    AppLanguage.resolve([Localizations.localeOf(context)]).name,
  );
  var _busy = false;

  void _pickLearning(CourseLanguage language) => setState(() {
    _learning = language;
    if (_base == language) _base = null;
  });

  Future<void> _start() async {
    final scope = AppScope.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.courseStartFailed;
    setState(() => _busy = true);
    try {
      await scope.courses.start(_learning!, _base!);
    } on Exception {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(failed)));
      return;
    }
    if (widget.closable) {
      navigator.pop();
      await scope.loadStudy();
    } else {
      await scope.loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final learning = _learning;
    final base = _base;
    final label = switch ((learning, base)) {
      (null, _) => l10n.coursePickLearning,
      (_, null) => l10n.coursePickBase,
      (final learning?, _) => l10n.courseStart(learning.name),
    };

    return SheetPage(
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
            )
          else
            AppBubble(
              color: AppPalette.white,
              foreground: c.header,
              child: const SpeechBubbleIcon(),
            ),
          PageHeader(
            title: l10n.coursePickTitle,
            subtitle: l10n.coursePickSubtitle,
          ),
        ],
      ),
      footer: AppButton(
        label: label,
        size: AppButtonSize.large,
        expand: true,
        loading: _busy,
        onPressed: learning == null || base == null ? null : _start,
      ),
      children: [
        _Section(
          title: l10n.courseLearnSection,
          child: Column(
            spacing: AppSpacing.s2,
            children: [
              for (final language in CourseLanguage.values)
                _LanguageOption(
                  language: language,
                  selected: language == learning,
                  onTap: () => _pickLearning(language),
                ),
            ],
          ),
        ),
        _Section(
          title: l10n.courseBaseSection,
          hint: l10n.courseBaseHint,
          child: SegmentedControl(
            options: [for (final l in CourseLanguage.values) l.nativeName],
            selected: base?.index,
            disabled: {?learning?.index},
            onChanged: (i) => setState(() => _base = CourseLanguage.values[i]),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.hint, required this.child});

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s3,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s1,
          children: [
            Semantics(
              header: true,
              child: Text(
                title.toUpperCase(),
                style: AppText.overline.copyWith(color: c.inkSoft),
              ),
            ),
            if (hint case final hint?)
              Text(hint, style: AppText.bodyMd.copyWith(color: c.inkSoft)),
          ],
        ),
        child,
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
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
            CourseBubble(language: language, active: selected),
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
                        ? language.nativeName
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
