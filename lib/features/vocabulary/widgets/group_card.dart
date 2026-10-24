import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/count_label.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group, required this.onTap});

  final TermGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final total = group.terms.length;
    final percent = total == 0 ? 0 : group.masteredCount * 100 ~/ total;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s3,
        children: [
          IconTile(icon: group.icon, accent: group.accent),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, style: AppText.titleSm),
              Text(
                total == 0 ? 'Sem termos ainda' : termsLabel(total),
                style: AppText.bodyMd.copyWith(color: c.inkSoft),
              ),
            ],
          ),
          const Spacer(),
          SegmentBar(
            total: total,
            height: 6,
            segments: [Segment(group.masteredCount, c.mastered)],
          ),
          Text(
            '$percent% dominado',
            style: AppText.pill.copyWith(
              color: c.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
