import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermTile extends StatelessWidget {
  const TermTile({
    super.key,
    required this.term,
    this.selecting = false,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final Term term;

  final bool selecting;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mastered = term.status == TermStatus.mastered;

    return Semantics(
      checked: selecting ? selected : null,
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        selected: selected,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Row(
          spacing: AppSpacing.s3,
          children: [
            if (selecting) AppCheckbox(checked: selected),
            Expanded(
              child: Row(
                spacing: AppSpacing.s2,
                children: [
                  Flexible(
                    child: Text(
                      term.text,
                      style: AppText.term,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppTag(label: context.l10n.termKind(term.kind.name)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: AppSpacing.s2,
              children: [
                StatusPill(
                  label: context.l10n.termStatus(term.status.name),
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
      ),
    );
  }
}
