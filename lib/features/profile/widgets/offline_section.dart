import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/profile/widgets/profile_section.dart';
import 'package:tagarela/l10n/l10n.dart';

class OfflineSection extends StatelessWidget {
  const OfflineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final speech = AppScope.of(context).speech;
    return ListenableBuilder(
      listenable: speech,
      builder: (context, _) {
        final l10n = context.l10n;
        final size = speech.model.sizeLabel;
        final (text, status, tone) = switch (speech.state) {
          SpeechModelState.ready => (
            l10n.modelReady(size),
            l10n.ready,
            StatusTone.primary,
          ),
          SpeechModelState.downloading => (
            l10n.modelDownloading(speech.percent, size),
            l10n.downloading,
            StatusTone.learning,
          ),
          SpeechModelState.missing || SpeechModelState.failed => (
            l10n.modelWaiting(size),
            l10n.waiting,
            StatusTone.neutral,
          ),
        };
        return ProfileSection(
          title: l10n.worksOffline,
          rows: [
            ProfileRow(
              icon: AppIcons.camera,
              accent: AppAccent.mango,
              title: l10n.photoText,
              text: l10n.photoTextHint,
              trailing: StatusPill(label: l10n.ready, tone: StatusTone.primary),
            ),
            ProfileRow(
              icon: AppIcons.audio,
              accent: AppAccent.coral,
              title: l10n.englishAudio,
              text: text,
              trailing: StatusPill(label: status, tone: tone),
            ),
          ],
        );
      },
    );
  }
}
