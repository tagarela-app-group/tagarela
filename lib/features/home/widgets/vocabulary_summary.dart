import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';

class VocabularySummary extends StatelessWidget {
  const VocabularySummary({
    super.key,
    required this.learning,
    required this.mastered,
    required this.weekGain,
    required this.onSeeAll,
  });

  final int learning;
  final int mastered;
  final int weekGain;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s2,
      children: [
        SectionHeader(
          title: 'Seu vocabulário',
          actionLabel: 'Ver tudo',
          onAction: onSeeAll,
        ),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s4,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total de termos',
                          style: AppText.label.copyWith(
                            color: c.inkSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text('${learning + mastered}', style: AppText.statLg),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: '+$weekGain esta semana',
                    tone: StatusTone.mastered,
                  ),
                ],
              ),
              SegmentBar(
                height: 10,
                semanticLabel: '$learning aprendendo, $mastered dominados',
                segments: [
                  Segment(learning, c.learning),
                  Segment(mastered, c.mastered),
                ],
              ),
              Row(
                spacing: AppSpacing.s3,
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Aprendendo',
                      value: learning,
                      dot: c.learning,
                      bg: c.learningSoft,
                      fg: c.learningText,
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: 'Dominado',
                      value: mastered,
                      dot: c.mastered,
                      bg: c.masteredSoft,
                      fg: c.masteredText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.dot,
    required this.bg,
    required this.fg,
  });

  final String label;
  final int value;
  final Color dot;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s1,
        children: [
          Row(
            spacing: 6,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              Text(label, style: AppText.label.copyWith(color: fg)),
            ],
          ),
          Text('$value', style: AppText.stat),
        ],
      ),
    );
  }
}
