import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class NinaAudio extends StatelessWidget {
  const NinaAudio({
    super.key,
    required this.text,
    required this.language,
    required this.voice,
    required this.onListen,
    required this.showText,
  });

  final String text;
  final CourseLanguage language;
  final Voice voice;
  final ValueChanged<VoiceSpeed> onListen;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) {
        final saying = voice.text == text ? voice.speaking : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s2,
          children: [
            Row(
              spacing: AppSpacing.s2,
              children: [
                AppIconButton(
                  icon: saying == VoiceSpeed.normal
                      ? AppIcons.stop
                      : AppIcons.play,
                  tooltip: saying == VoiceSpeed.normal
                      ? l10n.stop
                      : l10n.replyListen,
                  variant: AppIconButtonVariant.primary,
                  onPressed: () => onListen(VoiceSpeed.normal),
                ),
                Expanded(
                  child: Waveform(
                    progress: saying == null ? 0 : 1,
                    color: c.primary,
                    track: c.inkSoft,
                  ),
                ),
                ListenSlowButton(
                  playing: saying == VoiceSpeed.slow,
                  variant: AppButtonVariant.tonal,
                  onPressed: () => onListen(VoiceSpeed.slow),
                ),
              ],
            ),
            if (showText)
              Text(
                text,
                locale: Locale(language.name),
                style: AppText.bodyLg.copyWith(color: c.ink),
              ),
          ],
        );
      },
    );
  }
}
