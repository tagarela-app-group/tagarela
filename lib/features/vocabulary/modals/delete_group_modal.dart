import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/busy_action.dart';

class DeleteGroupModal extends StatefulWidget {
  const DeleteGroupModal({super.key, required this.group});

  final TermGroup group;

  @override
  State<DeleteGroupModal> createState() => _DeleteGroupModalState();
}

class _DeleteGroupModalState extends State<DeleteGroupModal> with BusyAction {
  Future<void> _delete() => runAction(() async {
    await AppScope.of(context).vocabulary.deleteGroup(widget.group.id);
    if (mounted) Navigator.pop(context, true);
  }, failureOf: (_) => context.l10n.deleteFailed);

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return AppModal(
      icon: AppIcons.delete,
      accent: AppAccent.coral,
      title: context.l10n.deleteGroupTitle(group.name),
      subtitle: context.l10n.deleteGroupSubtitle(group.terms.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s3,
        children: [
          if (failure case final error?) FormError(error),
          AppButton(
            label: context.l10n.deleteGroup,
            variant: AppButtonVariant.danger,
            expand: true,
            loading: busy,
            onPressed: _delete,
          ),
          AppButton(
            label: context.l10n.cancel,
            variant: AppButtonVariant.text,
            expand: true,
            onPressed: busy ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
