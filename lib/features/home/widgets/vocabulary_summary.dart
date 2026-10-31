import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class VocabularySummary extends StatelessWidget {
  const VocabularySummary({
    super.key,
    required this.learning,
    required this.mastered,
    required this.onSeeAll,
  });

  final int learning;
  final int mastered;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s2,
      children: [
        SectionHeader(
          title: context.l10n.yourVocabulary,
          actionLabel: context.l10n.seeAll,
          onAction: onSeeAll,
        ),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s4,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.totalTerms,
                    style: AppText.label.copyWith(
                      color: c.inkSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('${learning + mastered}', style: AppText.statLg),
                ],
              ),
              SegmentBar(
                height: 10,
                semanticLabel: context.l10n.learningMastered(
                  learning,
                  mastered,
                ),
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
                      label: context.l10n.termStatus(TermStatus.learning.name),
                      value: learning,
                      dot: c.learning,
                      bg: c.learningSoft,
                      fg: c.learningText,
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: context.l10n.termStatus(TermStatus.mastered.name),
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
