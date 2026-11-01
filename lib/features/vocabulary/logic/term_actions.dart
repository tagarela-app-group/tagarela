import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/logic/group_controller.dart';
import 'package:tagarela/features/vocabulary/modals/group_modal.dart';
import 'package:tagarela/features/vocabulary/modals/move_modal.dart';
import 'package:tagarela/l10n/l10n.dart';

mixin TermActions<T extends StatefulWidget> on State<T> {
  late final GroupController controller;

  @override
  void initState() {
    super.initState();
    controller = GroupController(AppScope.of(context).vocabulary);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget listening(WidgetBuilder builder) => ListenableBuilder(
    listenable: Listenable.merge([AppScope.of(context).vocabulary, controller]),
    builder: (context, _) => builder(context),
  );

  Widget cancelSelectionButton() => AppIconButton(
    icon: AppIcons.close,
    tooltip: context.l10n.cancelSelection,
    onPressed: () => controller.select(null),
    variant: AppIconButtonVariant.onHeader,
  );

  Widget selectAllButton(Iterable<Term> visible) => AppButton(
    label: context.l10n.selectAll,
    variant: AppButtonVariant.onHeader,
    size: AppButtonSize.small,
    onPressed: () => controller.selectAll(visible),
  );

  Future<void> pickTarget(Vocabulary data, List<TermEntry> entries) async {
    final origins = {for (final entry in entries) entry.group?.id};
    final from = origins.length == 1 ? entries.first.group : null;
    final target = await AppModal.show<MoveTarget>(
      context,
      (_) => MoveModal(
        groups: [
          for (final g in data.groups)
            if (from == null || g.id != from.id) g,
        ],
        count: entries.length,
        from: origins.length > 1 ? null : from?.name ?? context.l10n.ungrouped,
      ),
    );
    if (target == null || !mounted) return;
    final to =
        target.group ??
        await AppModal.show<TermGroup>(context, (_) => const GroupModal());
    if (to == null || !mounted) return;
    await _move(entries, to);
  }

  Future<void> _move(List<TermEntry> entries, TermGroup to) async {
    final vocabulary = AppScope.of(context).vocabulary;
    final ids = [for (final entry in entries) entry.term.id];
    final origins = <String?, List<String>>{};
    for (final entry in entries) {
      (origins[entry.group?.id] ??= []).add(entry.term.id);
    }
    final done = await controller.move(ids, to.id);
    if (!mounted) return;
    final l10n = context.l10n;
    _report(
      done,
      failure: l10n.moveFailed,
      title: l10n.termsMoved(ids.length),
      message: l10n.termsMovedTo(ids.length, to.name),
      undo: () async {
        for (final MapEntry(key: group, value: moved) in origins.entries) {
          await vocabulary.move(moved, group);
        }
      },
    );
  }

  Future<void> deleteTerms(List<String> ids) async {
    final vocabulary = AppScope.of(context).vocabulary;
    final done = await controller.delete(ids);
    if (!mounted) return;
    final l10n = context.l10n;
    _report(
      done,
      failure: l10n.deleteFailed,
      title: l10n.termsDeleted(ids.length),
      message: l10n.termsDeletedMessage(ids.length),
      undo: () => vocabulary.restoreTerms(ids),
    );
  }

  void _report(
    bool done, {
    required String failure,
    required String title,
    required String message,
    required Future<void> Function() undo,
  }) {
    if (!done) return AppToast.notice(context, failure);
    AppToast.show(
      context,
      title: title,
      message: message,
      actionLabel: context.l10n.undo,
      onAction: () async {
        try {
          await undo();
        } on Exception {
          if (mounted) AppToast.notice(context, context.l10n.undoFailed);
        }
      },
    );
  }
}
