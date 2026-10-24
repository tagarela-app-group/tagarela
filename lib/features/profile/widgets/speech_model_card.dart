import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/design_system/design_system.dart';

class SpeechModelCard extends StatelessWidget {
  const SpeechModelCard({super.key});

  @override
  Widget build(BuildContext context) {
    final speech = AppScope.of(context).speech;
    return ListenableBuilder(
      listenable: speech,
      builder: (context, _) {
        final c = context.colors;
        final size = speech.model.sizeLabel;
        final (status, tone, text) = switch (speech.state) {
          SpeechModelState.missing => (
            'Não baixado',
            StatusTone.neutral,
            'Transcreve o áudio no celular, sem internet. $size.',
          ),
          SpeechModelState.downloading => (
            'Baixando',
            StatusTone.learning,
            'Baixando ${speech.percent}% de $size.',
          ),
          SpeechModelState.ready => (
            'Pronto',
            StatusTone.primary,
            'O áudio é transcrito no celular. $size.',
          ),
          SpeechModelState.failed => (
            'Erro',
            StatusTone.alert,
            'Não deu pra baixar. Confira a internet.',
          ),
        };
        final action = switch (speech.state) {
          SpeechModelState.missing => ('Baixar modelo', speech.download),
          SpeechModelState.downloading => null,
          SpeechModelState.ready => ('Remover modelo', speech.remove),
          SpeechModelState.failed => ('Tentar de novo', speech.download),
        };

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s3,
            children: [
              Row(
                spacing: AppSpacing.s3,
                children: [
                  const IconTile(icon: AppIcons.audio, accent: AppAccent.coral),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'Transcrição offline',
                          style: AppText.bodyLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          text,
                          style: AppText.label.copyWith(
                            color: c.inkSoft,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(label: status, tone: tone),
                ],
              ),
              if (speech.state == SpeechModelState.downloading)
                SegmentBar(
                  total: 1,
                  segments: [Segment(speech.progress, c.primary)],
                  semanticLabel: 'Baixando ${speech.percent}%',
                ),
              if (action case (final label, final onPressed))
                AppButton(
                  label: label,
                  onPressed: onPressed,
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.small,
                  expand: true,
                ),
            ],
          ),
        );
      },
    );
  }
}
