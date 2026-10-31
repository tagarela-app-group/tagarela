import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/modals/base_language_modal.dart';
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
                _Hello(label: l10n.courseBaseSection, language: _base),
                _Hello(
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
          child: _BaseCard(language: _base, onTap: _chooseBase),
        ),
        _Section(
          title: l10n.courseLearnSection,
          child: Column(
            spacing: AppSpacing.s2,
            children: [
              for (final language in CourseLanguage.values)
                if (language != _base)
                  _LanguageOption(
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

class _Hello extends StatelessWidget {
  const _Hello({required this.label, this.language, this.mine = false});

  final String label;
  final CourseLanguage? language;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final language = this.language;
    final flag = language == null
        ? null
        : FlagBadge(country: language.country, size: 16);
    final Widget balloon = switch (language) {
      null => SpeechBalloon(
        color: c.headerChip,
        mirrored: true,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: const TypingDots(color: AppPalette.white, size: 7),
      ),
      final language => SpeechBalloon(
        color: mine ? c.headerChip : c.surface,
        mirrored: mine,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        child: Text(
          language.hello,
          locale: language.locale,
          textAlign: mine ? TextAlign.end : TextAlign.start,
          style: AppText.titleMd.copyWith(
            color: mine ? AppPalette.white : c.ink,
          ),
        ),
      ),
    };
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: mine ? AppSpacing.s14 : 0,
        end: mine ? 0 : AppSpacing.s14,
      ),
      child: Align(
        alignment: mine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                if (!mine) ?flag,
                Text(
                  label.toUpperCase(),
                  style: AppText.overline.copyWith(color: c.onHeaderSoft),
                ),
                if (mine) ?flag,
              ],
            ),
            if (language == null || !mine)
              balloon
            else
              _Pop(key: ValueKey(language), child: balloon),
          ],
        ),
      ),
    );
  }
}

class _Pop extends StatelessWidget {
  const _Pop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.slow,
      curve: AppMotion.spring,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.scale(
          scale: 0.6 + 0.4 * t,
          alignment: AlignmentDirectional.bottomEnd,
          child: child,
        ),
      ),
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

class _BaseCard extends StatelessWidget {
  const _BaseCard({required this.language, required this.onTap});

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
              spacing: 2,
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
