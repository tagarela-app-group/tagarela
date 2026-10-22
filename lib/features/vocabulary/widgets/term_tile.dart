import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class TermTile extends StatelessWidget {
  const TermTile({super.key, required this.term});

  final Term term;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mastered = term.status == TermStatus.mastered;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        spacing: AppSpacing.s3,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Row(
                  spacing: AppSpacing.s2,
                  children: [
                    Flexible(
                      child: Text(
                        term.text,
                        style: AppText.term,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppTag(label: term.kind.label),
                  ],
                ),
                Text(
                  term.translation,
                  style: AppText.bodyMd.copyWith(color: c.inkSoft),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: AppSpacing.s2,
            children: [
              StatusPill(
                label: term.status.label,
                tone: mastered ? StatusTone.mastered : StatusTone.learning,
              ),
              LevelDots(
                level: term.level,
                color: mastered ? c.mastered : c.learning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
