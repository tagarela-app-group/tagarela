import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/term_page.dart';
import 'package:tagarela/features/vocabulary/logic/group_controller.dart';
import 'package:tagarela/features/vocabulary/modals/delete_group_modal.dart';
import 'package:tagarela/features/vocabulary/modals/group_menu_modal.dart';
import 'package:tagarela/features/vocabulary/modals/group_modal.dart';
import 'package:tagarela/features/vocabulary/modals/move_modal.dart';
import 'package:tagarela/features/vocabulary/widgets/group_header.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/group_style.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, required String this.groupId});

  const GroupPage.ungrouped({super.key}) : groupId = null;

  final String? groupId;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final GroupController _controller;
  TermGroup? _group;

  @override
  void initState() {
    super.initState();
    _controller = GroupController(AppScope.of(context).vocabulary);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openMenu(TermGroup group) async {
    final action = await AppModal.show<GroupMenuAction>(
      context,
      (_) => GroupMenuModal(group: group),
    );
    if (!mounted) return;
    switch (action) {
      case GroupMenuAction.edit:
        await AppModal.show<TermGroup>(
          context,
          (_) => GroupModal(group: group),
        );
      case GroupMenuAction.select:
        _controller.select({});
      case GroupMenuAction.delete:
        final deleted = await AppModal.show<bool>(
          context,
          (_) => DeleteGroupModal(group: group),
        );
        if (deleted == true && mounted) Navigator.of(context).pop(group);
      case null:
    }
  }

  Future<void> _pickTarget(
    Vocabulary data,
    TermGroup? from,
    List<Term> terms,
  ) async {
    final ids = _controller.selectedIn(terms);
    final target = await AppModal.show<MoveTarget>(
      context,
      (_) => MoveModal(
        groups: [
          for (final g in data.groups)
            if (g.id != from?.id) g,
        ],
        count: ids.length,
        from: from?.name ?? context.l10n.ungrouped,
      ),
    );
    if (target == null || !mounted) return;
    final to =
        target.group ??
        await AppModal.show<TermGroup>(context, (_) => const GroupModal());
    if (to == null || !mounted) return;
    await _move(ids, from: from, to: to);
  }

  Future<void> _move(
    List<String> ids, {
    required TermGroup? from,
    required TermGroup to,
  }) async {
    final vocabulary = AppScope.of(context).vocabulary;
    final done = await _controller.move(ids, to.id);
    if (!mounted) return;
    final l10n = context.l10n;
    _report(
      done,
      failure: l10n.moveFailed,
      title: l10n.termsMoved(ids.length),
      message: l10n.termsMovedTo(ids.length, to.name),
      undo: () => vocabulary.move(ids, from?.id),
    );
  }

  Future<void> _delete(List<Term> terms) async {
    final ids = _controller.selectedIn(terms);
    final vocabulary = AppScope.of(context).vocabulary;
    final done = await _controller.delete(ids);
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

  @override
  Widget build(BuildContext context) {
    final vocabulary = AppScope.of(context).vocabulary;

    return ListenableBuilder(
      listenable: Listenable.merge([vocabulary, _controller]),
      builder: (context, _) {
        final data = vocabulary.data ?? const Vocabulary();
        final id = widget.groupId;
        if (id != null) _group = data.group(id) ?? _group;
        final group = _group;
        final terms = id == null ? data.ungrouped : group?.terms ?? const [];
        final filtered = group != null && terms.isNotEmpty;
        final visible = filtered ? group.termsWith(_controller.status) : terms;
        final selected = _controller.selected;
        final change = _controller.change;

        return PopScope(
          canPop: selected == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) return _controller.select(null);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: AppPage(
            header: GroupHeader(
              icon: group?.glyph ?? AppIcons.ungrouped,
              name: group?.name ?? context.l10n.ungrouped,
              meta: _meta(context.l10n, group, terms, selected),
              bar: filtered ? group : null,
              leading: selected == null
                  ? AppIconButton(
                      icon: AppIcons.back,
                      tooltip: context.l10n.back,
                      onPressed: () => Navigator.of(context).pop(),
                      variant: AppIconButtonVariant.onHeader,
                    )
                  : AppIconButton(
                      icon: AppIcons.close,
                      tooltip: context.l10n.cancelSelection,
                      onPressed: () => _controller.select(null),
                      variant: AppIconButtonVariant.onHeader,
                    ),
              trailing: switch ((selected, group)) {
                (null, final group?) => AppIconButton(
                  icon: AppIcons.more,
                  tooltip: context.l10n.moreOptions,
                  onPressed: () => _openMenu(group),
                  variant: AppIconButtonVariant.onHeader,
                ),
                _ when terms.isEmpty => null,
                (null, null) => AppButton(
                  label: context.l10n.select,
                  variant: AppButtonVariant.onHeader,
                  size: AppButtonSize.small,
                  onPressed: () => _controller.select({}),
                ),
                _ => AppButton(
                  label: context.l10n.selectAll,
                  variant: AppButtonVariant.onHeader,
                  size: AppButtonSize.small,
                  onPressed: () => _controller.selectAll(visible),
                ),
              },
            ),
            gap: AppSpacing.s3,
            centerLast: terms.isEmpty,
            footer: selected == null
                ? null
                : Row(
                    spacing: AppSpacing.s3,
                    children: [
                      AppButton(
                        label: context.l10n.delete,
                        leading: const Icon(
                          AppIcons.delete,
                          size: AppIconSize.lg,
                        ),
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.large,
                        loading: change == GroupChange.deleting,
                        onPressed:
                            selected.isEmpty || change == GroupChange.moving
                            ? null
                            : () => _delete(terms),
                      ),
                      Expanded(
                        child: AppButton(
                          label: context.l10n.moveTerms(selected.length),
                          size: AppButtonSize.large,
                          expand: true,
                          loading: change == GroupChange.moving,
                          onPressed:
                              selected.isEmpty || change == GroupChange.deleting
                              ? null
                              : () => _pickTarget(data, group, terms),
                        ),
                      ),
                    ],
                  ),
            children: [
              if (terms.isEmpty)
                id == null
                    ? StateMessage(
                        icon: AppIcons.ungrouped,
                        title: context.l10n.allOrganized,
                        message: context.l10n.allOrganizedMessage,
                      )
                    : StateMessage(
                        icon: group?.glyph ?? AppIcons.vocabulary,
                        accent: group?.accent ?? AppAccent.violet,
                        title: context.l10n.groupEmptyTitle,
                        message: context.l10n.groupEmptyMessage,
                      )
              else ...[
                if (id == null)
                  Text(
                    context.l10n.ungroupedHelp,
                    style: AppText.bodyMd.copyWith(
                      color: context.colors.inkSoft,
                    ),
                  ),
                if (filtered)
                  SegmentedControl(
                    options: [
                      for (final status in GroupController.filters)
                        switch (status) {
                          final status? => context.l10n.termStatus(status.name),
                          null => context.l10n.allCount(terms.length),
                        },
                    ],
                    selected: _controller.filter,
                    onChanged: _controller.showFilter,
                  ),
                for (final term in visible)
                  TermTile(
                    term: term,
                    selecting: selected != null,
                    selected: selected?.contains(term.id) ?? false,
                    onTap: selected == null
                        ? () => TermPage.open(context, term)
                        : () => _controller.toggle(term.id),
                    onLongPress: selected == null
                        ? () => _controller.select({term.id})
                        : null,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _meta(
    AppLocalizations l10n,
    TermGroup? group,
    List<Term> terms,
    Set<String>? selected,
  ) => switch (selected?.length) {
    final int n => l10n.selectionMeta(n),
    null when group == null =>
      terms.isEmpty ? l10n.nothingToOrganize : l10n.termsToGroup(terms.length),
    null when terms.isEmpty => l10n.noTermsYet,
    null => l10n.termCountMastered(terms.length, group.masteredCount),
  };
}
