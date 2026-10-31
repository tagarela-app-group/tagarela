import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/term_page.dart';
import 'package:tagarela/features/vocabulary/modals/delete_group_modal.dart';
import 'package:tagarela/features/vocabulary/modals/group_modal.dart';
import 'package:tagarela/features/vocabulary/modals/move_modal.dart';
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
  static const _filters = [null, TermStatus.learning, TermStatus.mastered];

  int _filter = 0;
  Set<String>? _selected;
  TermGroup? _group;
  bool _moving = false;
  bool _deleting = false;

  void _select(Set<String>? selected) => setState(() => _selected = selected);

  void _toggle(String id) => _select(
    _selected!.contains(id)
        ? ({..._selected!}..remove(id))
        : {..._selected!, id},
  );

  Future<void> _openMenu(TermGroup group) async {
    final action = await AppModal.show<_MenuAction>(
      context,
      (_) => _GroupMenu(group: group),
    );
    if (!mounted) return;
    switch (action) {
      case _MenuAction.edit:
        await AppModal.show<TermGroup>(
          context,
          (_) => GroupModal(group: group),
        );
      case _MenuAction.select:
        _select({});
      case _MenuAction.delete:
        final deleted = await AppModal.show<bool>(
          context,
          (_) => DeleteGroupModal(group: group),
        );
        if (deleted == true && mounted) Navigator.of(context).pop(group);
      case null:
    }
  }

  List<String> _selectedIn(List<Term> terms) => [
    for (final t in terms)
      if (_selected!.contains(t.id)) t.id,
  ];

  Future<void> _pickTarget(
    Vocabulary data,
    TermGroup? from,
    List<Term> terms,
  ) async {
    final ids = _selectedIn(terms);
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
    setState(() => _moving = true);
    try {
      await vocabulary.move(ids, to.id);
    } on Exception {
      if (!mounted) return;
      setState(() => _moving = false);
      AppToast.notice(context, context.l10n.moveFailed);
      return;
    }
    if (!mounted) return;
    setState(() {
      _moving = false;
      _selected = null;
    });
    AppToast.show(
      context,
      title: context.l10n.termsMoved(ids.length),
      message: context.l10n.termsMovedTo(ids.length, to.name),
      actionLabel: context.l10n.undo,
      onAction: () async {
        try {
          await vocabulary.move(ids, from?.id);
        } on Exception {
          if (mounted) AppToast.notice(context, context.l10n.undoFailed);
        }
      },
    );
  }

  Future<void> _delete(List<Term> terms) async {
    final ids = _selectedIn(terms);
    final vocabulary = AppScope.of(context).vocabulary;
    setState(() => _deleting = true);
    try {
      await vocabulary.deleteTerms(ids);
    } on Exception {
      if (!mounted) return;
      setState(() => _deleting = false);
      AppToast.notice(context, context.l10n.deleteFailed);
      return;
    }
    if (!mounted) return;
    setState(() {
      _deleting = false;
      _selected = null;
    });
    AppToast.show(
      context,
      title: context.l10n.termsDeleted(ids.length),
      message: context.l10n.termsDeletedMessage(ids.length),
      actionLabel: context.l10n.undo,
      onAction: () async {
        try {
          await vocabulary.restoreTerms(ids);
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
      listenable: vocabulary,
      builder: (context, _) {
        final data = vocabulary.data ?? const Vocabulary();
        final id = widget.groupId;
        if (id != null) _group = data.group(id) ?? _group;
        final group = _group;
        final terms = id == null ? data.ungrouped : group?.terms ?? const [];
        final filtered = group != null && terms.isNotEmpty;
        final visible = filtered ? group.termsWith(_filters[_filter]) : terms;
        final selected = _selected;

        return PopScope(
          canPop: selected == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) return _select(null);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: AppPage(
            header: _GroupHeader(
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
                      onPressed: () => _select(null),
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
                  onPressed: () => _select({}),
                ),
                _ => AppButton(
                  label: context.l10n.selectAll,
                  variant: AppButtonVariant.onHeader,
                  size: AppButtonSize.small,
                  onPressed: () =>
                      _select({...?selected, for (final t in visible) t.id}),
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
                        leading: const Icon(AppIcons.delete, size: 20),
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.large,
                        loading: _deleting,
                        onPressed: selected.isEmpty || _moving
                            ? null
                            : () => _delete(terms),
                      ),
                      Expanded(
                        child: AppButton(
                          label: context.l10n.moveTerms(selected.length),
                          size: AppButtonSize.large,
                          expand: true,
                          loading: _moving,
                          onPressed: selected.isEmpty || _deleting
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
                      for (final status in _filters)
                        switch (status) {
                          final status? => context.l10n.termStatus(status.name),
                          null => context.l10n.allCount(terms.length),
                        },
                    ],
                    selected: _filter,
                    onChanged: (i) => setState(() => _filter = i),
                  ),
                for (final term in visible)
                  TermTile(
                    term: term,
                    selecting: selected != null,
                    selected: selected?.contains(term.id) ?? false,
                    onTap: selected == null
                        ? () => TermPage.open(context, term)
                        : () => _toggle(term.id),
                    onLongPress: selected == null
                        ? () => _select({term.id})
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

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.icon,
    required this.name,
    required this.meta,
    required this.bar,
    required this.leading,
    required this.trailing,
  });

  final IconData icon;
  final String name;
  final String meta;
  final TermGroup? bar;
  final Widget leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      spacing: 14,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [leading, ?trailing],
        ),
        PageHeader(
          title: name,
          subtitle: meta,
          leading: AppBubble(
            size: 52,
            color: AppPalette.white,
            foreground: c.header,
            child: Icon(icon),
          ),
        ),
        if (bar case final group?)
          SegmentBar(
            gap: 3,
            semanticLabel: context.l10n.learningMastered(
              group.terms.length - group.masteredCount,
              group.masteredCount,
            ),
            segments: [
              Segment(
                group.terms.length - group.masteredCount,
                AppPalette.mango,
              ),
              Segment(group.masteredCount, AppPalette.mint),
            ],
          ),
      ],
    );
  }
}

enum _MenuAction { edit, select, delete }

class _GroupMenu extends StatelessWidget {
  const _GroupMenu({required this.group});

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
            onTap: () => Navigator.pop(context, _MenuAction.edit),
          ),
          if (group.terms.isNotEmpty)
            OptionRow(
              icon: AppIcons.move,
              accent: AppAccent.violet,
              title: context.l10n.selectTerms,
              subtitle: context.l10n.selectTermsHint,
              onTap: () => Navigator.pop(context, _MenuAction.select),
            ),
          OptionRow(
            icon: AppIcons.delete,
            accent: AppAccent.coral,
            title: context.l10n.deleteGroup,
            subtitle: context.l10n.deleteGroupHint,
            onTap: () => Navigator.pop(context, _MenuAction.delete),
          ),
        ],
      ),
    );
  }
}
