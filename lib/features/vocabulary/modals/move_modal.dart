import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/group_style.dart';

typedef MoveTarget = ({TermGroup? group});

class MoveModal extends StatelessWidget {
  const MoveModal({
    super.key,
    required this.groups,
    required this.count,
    required this.from,
  });

  final List<TermGroup> groups;
  final int count;
  final String from;

  @override
  Widget build(BuildContext context) {
    void pick(TermGroup? group) =>
        Navigator.pop<MoveTarget>(context, (group: group));

    return AppModal(
      title: context.l10n.moveModalTitle,
      subtitle: context.l10n.moveModalSubtitle(
        context.l10n.termCount(count),
        from,
      ),
      child: groups.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StateMessage(
                  icon: AppIcons.newGroup,
                  title: context.l10n.noGroupsTitle,
                  message: context.l10n.noGroupsMessage,
                ),
                AppButton(
                  label: context.l10n.createGroup,
                  expand: true,
                  onPressed: () => pick(null),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s2,
              children: [
                OptionRow(
                  icon: AppIcons.add,
                  accent: AppAccent.violet,
                  title: context.l10n.newGroup,
                  dashed: true,
                  trailing: const SizedBox.shrink(),
                  onTap: () => pick(null),
                ),
                for (final group in groups)
                  OptionRow(
                    icon: group.glyph,
                    accent: group.accent,
                    title: group.name,
                    subtitle: group.terms.isEmpty
                        ? context.l10n.noTermsInGroupYet
                        : context.l10n.termCount(group.terms.length),
                    onTap: () => pick(group),
                  ),
              ],
            ),
    );
  }
}
