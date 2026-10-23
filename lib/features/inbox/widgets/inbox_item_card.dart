import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class InboxItemCard extends StatelessWidget {
  const InboxItemCard({
    super.key,
    required this.item,
    this.onAdd,
    this.onDiscard,
  });

  final InboxItem item;
  final VoidCallback? onAdd;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final suggestion = item.suggestion;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s3,
        children: [
          _SourceRow(item: item),
          if (item.source == CaptureSource.audio)
            _AudioClip(duration: item.content)
          else
            Text(item.content, style: AppText.titleMd),
          if (suggestion != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: AppSpacing.s3,
              ),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s2,
                children: [
                  Text(
                    suggestion.translation,
                    style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    spacing: AppSpacing.s2,
                    children: [
                      AppTag(label: suggestion.kind.label),
                      AppTag(label: '→ ${suggestion.groupName}'),
                    ],
                  ),
                ],
              ),
            ),
          switch (item.status) {
            InboxStatus.ready => Row(
              spacing: AppSpacing.s2,
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Descartar',
                    onPressed: onDiscard,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.small,
                    expand: true,
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: 'Adicionar',
                    onPressed: onAdd,
                    size: AppButtonSize.small,
                    expand: true,
                  ),
                ),
              ],
            ),
            InboxStatus.analyzing => const _StatusLine(
              icon: AppIcons.review,
              text: 'Transcrevendo e buscando o significado…',
            ),
            InboxStatus.queued => const _StatusLine(
              icon: AppIcons.offline,
              text: 'Sem conexão. Analisamos assim que a rede voltar.',
            ),
          },
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.item});

  final InboxItem item;

  @override
  Widget build(BuildContext context) {
    final (icon, accent) = switch (item.source) {
      CaptureSource.photo => (AppIcons.camera, AppAccent.mango),
      CaptureSource.audio => (AppIcons.audio, AppAccent.coral),
      CaptureSource.text => (AppIcons.text, AppAccent.violet),
    };
    final (status, tone) = switch (item.status) {
      InboxStatus.ready => ('Pronto', StatusTone.primary),
      InboxStatus.analyzing => ('Analisando', StatusTone.learning),
      InboxStatus.queued => ('Na fila', StatusTone.neutral),
    };

    return Row(
      spacing: AppSpacing.s2,
      children: [
        IconTile(icon: icon, accent: accent, size: 28),
        Expanded(
          child: Text(
            '${item.source.label} · ${item.capturedAt}',
            style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
          ),
        ),
        StatusPill(label: status, tone: tone),
      ],
    );
  }
}

class _AudioClip extends StatelessWidget {
  const _AudioClip({required this.duration});

  final String duration;

  static const _bars = [
    8,
    14,
    22,
    12,
    26,
    30,
    18,
    10,
    24,
    32,
    20,
    14,
    8,
    16,
    28,
    22,
    12,
    6,
    14,
    24,
    16,
    10,
    6,
    10,
    6,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        spacing: AppSpacing.s3,
        children: [
          AppIconButton(
            icon: AppIcons.play,
            tooltip: 'Ouvir gravação',
            onPressed: () {},
            variant: AppIconButtonVariant.primary,
            size: 40,
          ),
          Expanded(
            child: ExcludeSemantics(
              child: SizedBox(
                height: 32,
                child: ClipRect(
                  child: Row(
                    spacing: 3,
                    children: [
                      for (final h in _bars)
                        Container(
                          width: 3,
                          height: h.toDouble(),
                          decoration: BoxDecoration(
                            color: c.primaryText,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Text(
            duration,
            style: AppText.label.copyWith(
              color: c.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final soft = context.colors.inkSoft;
    return Row(
      spacing: AppSpacing.s2,
      children: [
        Icon(icon, size: 18, color: soft),
        Expanded(
          child: Text(text, style: AppText.bodyMd.copyWith(color: soft)),
        ),
      ],
    );
  }
}
