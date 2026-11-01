import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/shared/logic/review_time.dart';
import 'package:tagarela/shared/widgets/phonetic_text.dart';
import 'package:tagarela/features/term/widgets/term_top_bar.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermHeader extends StatelessWidget {
  const TermHeader({
    super.key,
    required this.term,
    required this.group,
    required this.phonetic,
    required this.language,
    required this.voice,
  });

  final Term term;
  final TermGroup? group;
  final String? phonetic;
  final CourseLanguage language;
  final Voice voice;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final mastered = term.status == TermStatus.mastered;
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) {
        final speaking = voice.speaking;
        final saying = voice.text == term.text ? speaking : null;
        void speak(VoiceSpeed speed) => saying == speed
            ? voice.stop()
            : voice.speak(term.text, language, speed: speed);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s4,
          children: [
            TermTopBar(group: group),
            SpeechBalloon(
              color: c.surface,
              radius: AppRadius.xl,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s5,
                AppSpacing.s4,
                AppSpacing.s5,
                AppSpacing.s45,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s05,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s15),
                    child: AppTag(label: l10n.termKind(term.kind.name)),
                  ),
                  Semantics(
                    label: term.text,
                    excludeSemantics: true,
                    child: _Spoken(
                      text: term.text,
                      word: saying == null ? null : voice.word,
                      locale: Locale(language.name),
                    ),
                  ),
                  if (phonetic case final phonetic?)
                    PhoneticText(
                      phonetic,
                      style: AppText.bodyLg.copyWith(color: c.inkSoft),
                      stressColor: c.ink,
                    ),
                ],
              ),
            ),
            Row(
              spacing: AppSpacing.s25,
              children: [
                AppIconButton(
                  icon: saying == VoiceSpeed.normal
                      ? AppIcons.stop
                      : AppIcons.listen,
                  tooltip: saying == VoiceSpeed.normal
                      ? l10n.stop
                      : l10n.listenPronunciation,
                  onPressed: () => speak(VoiceSpeed.normal),
                  variant: AppIconButtonVariant.onHeaderSolid,
                  size: AppBubbleSize.xxl,
                ),
                ListenSlowButton(
                  playing: saying == VoiceSpeed.slow,
                  onPressed: () => speak(VoiceSpeed.slow),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: AppSpacing.s15,
                  children: [
                    StatusPill(
                      label: l10n.termStatus(term.status.name),
                      tone: mastered
                          ? StatusTone.mastered
                          : StatusTone.learning,
                    ),
                    LevelDots(
                      level: term.level,
                      color: mastered ? c.mastered : c.learning,
                      track: c.headerChip,
                    ),
                  ],
                ),
              ],
            ),
            if ((term.dueAt, term.intervalDays) case (
              final due?,
              final interval?,
            ))
              Text(
                '${returnsIn(l10n, due, DateTime.now())} · '
                '${l10n.termMemory(interval.round())}',
                style: AppText.bodyMd.copyWith(color: c.onHeaderSoft),
              ),
          ],
        );
      },
    );
  }
}

class _Spoken extends StatelessWidget {
  const _Spoken({required this.text, required this.word, required this.locale});

  final String text;
  final (int, int)? word;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = AppText.display.copyWith(color: c.ink);
    final range = word;
    if (range == null || range.$1 < 0 || range.$2 > text.length) {
      return Text(text, locale: locale, style: style);
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, range.$1)),
          TextSpan(
            text: text.substring(range.$1, range.$2),
            style: TextStyle(color: c.primaryText),
          ),
          TextSpan(text: text.substring(range.$2)),
        ],
      ),
      locale: locale,
      style: style,
    );
  }
}
