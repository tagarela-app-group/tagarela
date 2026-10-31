import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/group_style.dart';

enum GroupMenuAction { edit, select, delete }

class GroupMenuModal extends StatelessWidget {
  const GroupMenuModal({super.key, required this.group});

  final TermGroup group;

  @override
  Widget build(BuildContext context) {
    return AppModal(
      icon: group.glyph,
      accent: group.accent,
      title: group.name,
      subtitle: context.l10n.termCount(group.terms.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s3,
        children: [
          OptionRow(
            icon: AppIcons.edit,
            accent: AppAccent.violet,
            title: context.l10n.editGroup,
            subtitle: context.l10n.editGroupHint,
            onTap: () => Navigator.pop(context, GroupMenuAction.edit),
          ),
          if (group.terms.isNotEmpty)
            OptionRow(
              icon: AppIcons.move,
              accent: AppAccent.violet,
              title: context.l10n.selectTerms,
              subtitle: context.l10n.selectTermsHint,
              onTap: () => Navigator.pop(context, GroupMenuAction.select),
            ),
          OptionRow(
            icon: AppIcons.delete,
            accent: AppAccent.coral,
            title: context.l10n.deleteGroup,
            subtitle: context.l10n.deleteGroupHint,
            onTap: () => Navigator.pop(context, GroupMenuAction.delete),
          ),
        ],
      ),
    );
  }
}
