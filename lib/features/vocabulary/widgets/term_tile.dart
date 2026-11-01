import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/group_style.dart';

class TermTile extends StatelessWidget {
  const TermTile({
    super.key,
    required this.term,
    this.showGroup = false,
    this.group,
    this.onAddToGroup,
    this.selecting = false,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final Term term;
  final bool showGroup;
  final TermGroup? group;
  final VoidCallback? onAddToGroup;

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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s35,
        ),
        selected: selected,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Row(
          spacing: AppSpacing.s3,
          children: [
            if (selecting) AppCheckbox(checked: selected),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s1,
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
                      AppTag(label: context.l10n.termKind(term.kind.name)),
                    ],
                  ),
                  if (showGroup)
                    switch (group) {
                      final group? => DotLabel(
                        label: group.name,
                        dot: c.accent(group.accent).fg,
                        color: c.inkSoft,
                      ),
                      null when selecting => const SizedBox.shrink(),
                      null => AppButton(
                        label: context.l10n.addToGroup,
                        leading: const Icon(AppIcons.add, size: AppIconSize.sm),
                        variant: AppButtonVariant.text,
                        size: AppButtonSize.small,
                        onPressed: onAddToGroup,
                      ),
                    },
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
