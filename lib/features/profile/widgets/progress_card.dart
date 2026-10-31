import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.terms,
    required this.learning,
    required this.mastered,
  });

  final int terms;
  final int learning;
  final int mastered;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _Stat(terms, context.l10n.statTerms, c.primary)),
          Expanded(
            child: _Stat(learning, context.l10n.statLearning, c.learning),
          ),
          Expanded(
            child: _Stat(mastered, context.l10n.statMastered, c.mastered),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.dot);

  final int value;
  final String label;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s1,
          children: [
            Text('$value', style: AppText.stat),
            DotLabel(
              label: label,
              dot: dot,
              color: context.colors.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
