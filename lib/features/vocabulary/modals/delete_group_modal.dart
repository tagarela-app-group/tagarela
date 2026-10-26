import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class DeleteGroupModal extends StatefulWidget {
  const DeleteGroupModal({super.key, required this.group});

  final TermGroup group;

  @override
  State<DeleteGroupModal> createState() => _DeleteGroupModalState();
}

class _DeleteGroupModalState extends State<DeleteGroupModal> {
  var _busy = false;
  String? _error;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AppScope.of(context).vocabulary.deleteGroup(widget.group.id);
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.l10n.deleteFailed;
      });
    }
  }

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
          if (_error case final error?)
            Text(
              error,
              style: AppText.bodyMd.copyWith(color: context.colors.alert),
            ),
          AppButton(
            label: context.l10n.deleteGroup,
            variant: AppButtonVariant.danger,
            expand: true,
            loading: _busy,
            onPressed: _delete,
          ),
          AppButton(
            label: context.l10n.cancel,
            variant: AppButtonVariant.text,
            expand: true,
            onPressed: _busy ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
