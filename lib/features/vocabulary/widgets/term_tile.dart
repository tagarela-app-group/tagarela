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

  static const _groupMaxWidth = 120.0;

  final Term term;
  final bool showGroup;
  final TermGroup? group;
  final VoidCallback? onAddToGroup;

  final bool selecting;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  Widget? _groupSlot(BuildContext context) {
    if (!showGroup) return null;
    if (group case final group?) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _groupMaxWidth),
        child: StatusPill.accent(label: group.name, accent: group.accent),
      );
    }
    if (selecting) return null;
    return PillButton(
      label: context.l10n.addToGroup,
      icon: AppIcons.newGroup,
      onPressed: onAddToGroup,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
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
            if (selecting)
              AppCheckbox(checked: selected)
            else
              LevelRing(
                level: term.level,
                color: mastered ? c.mastered : c.learning,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term.text,
                    style: AppText.term,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${l10n.termKind(term.kind.name)} · '),
                        TextSpan(
                          text: l10n.termStatus(term.status.name),
                          style: TextStyle(
                            color: mastered ? c.masteredText : c.learningText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    style: AppText.label.copyWith(
                      color: c.inkSoft,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ?_groupSlot(context),
          ],
        ),
      ),
    );
  }
}
