import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/profile/widgets/profile_section.dart';

class OfflineSection extends StatelessWidget {
  const OfflineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final speech = AppScope.of(context).speech;
    return ListenableBuilder(
      listenable: speech,
      builder: (context, _) {
        final size = speech.model.sizeLabel;
        final (text, status, tone) = switch (speech.state) {
          SpeechModelState.ready => (
            'Transcrito no celular · modelo de $size',
            'Pronto',
            StatusTone.primary,
          ),
          SpeechModelState.downloading => (
            'Baixando o modelo: ${speech.percent}% de $size',
            'Baixando',
            StatusTone.learning,
          ),
          SpeechModelState.missing || SpeechModelState.failed => (
            'O modelo de $size baixa sozinho quando tiver internet',
            'Esperando',
            StatusTone.neutral,
          ),
        };
        return ProfileSection(
          title: 'Funciona sem internet',
          rows: [
            const ProfileRow(
              icon: AppIcons.camera,
              accent: AppAccent.mango,
              title: 'Texto de fotos',
              text: 'Lido no celular, sem enviar a foto',
              trailing: StatusPill(label: 'Pronto', tone: StatusTone.primary),
            ),
            ProfileRow(
              icon: AppIcons.audio,
              accent: AppAccent.coral,
              title: 'Áudio em inglês',
              text: text,
              trailing: StatusPill(label: status, tone: tone),
            ),
          ],
        );
      },
    );
  }
}
