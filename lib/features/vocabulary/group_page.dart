import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/term_page.dart';
import 'package:tagarela/features/vocabulary/logic/groupcontroller.dart';
import 'package:tagarela/features/vocabulary/logic/term_actions.dart';
import 'package:tagarela/features/vocabulary/modals/delete_group_modal.dart';
import 'package:tagarela/features/vocabulary/modals/group_menu_modal.dart';
import 'package:tagarela/features/vocabulary/modals/group_modal.dart';
import 'package:tagarela/features/vocabulary/widgets/group_header.dart';
import 'package:tagarela/features/vocabulary/widgets/selection_bar.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/group_style.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> with TermActions {
  TermGroup? _group;

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
        controller.select({});
      case GroupMenuAction.delete:
        final deleted = await AppModal.show<bool>(
          context,
          (_) => DeleteGroupModal(group: group),
        );
        if (deleted == true && mounted) Navigator.of(context).pop(group);
      case null:
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabulary = AppScope.of(context).vocabulary;

    return listening((context) {
      final data = vocabulary.data ?? const Vocabulary();
      _group = data.group(widget.groupId) ?? _group;
      final group = _group;
      final terms = group?.terms ?? const <Term>[];
      final filtered = group != null && terms.isNotEmpty;
      final visible = filtered ? group.termsWith(controller.status) : terms;
      final selected = controller.selected;

      return PopScope(
        canPop: selected == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) return controller.select(null);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: AppPage(
          header: GroupHeader(
            icon: group?.glyph ?? AppIcons.vocabulary,
            name: group?.name ?? '',
            meta: _meta(context.l10n, terms, group, selected),
            bar: filtered ? group : null,
            leading: selected == null
                ? AppIconButton(
                    icon: AppIcons.back,
                    tooltip: context.l10n.back,
                    onPressed: () => Navigator.of(context).pop(),
                    variant: AppIconButtonVariant.onHeader,
                  )
                : cancelSelectionButton(),
            trailing: switch ((selected, group)) {
              (null, final group?) => AppIconButton(
                icon: AppIcons.more,
                tooltip: context.l10n.moreOptions,
                onPressed: () => _openMenu(group),
                variant: AppIconButtonVariant.onHeader,
              ),
              _ when terms.isEmpty => null,
              _ => selectAllButton(visible),
            },
          ),
          gap: AppSpacing.s3,
          centerLast: terms.isEmpty,
          footer: selected == null
              ? null
              : SelectionBar(
                  count: selected.length,
                  change: controller.change,
                  onDelete: () => deleteTerms(controller.selectedIn(terms)),
                  onMove: () => pickTarget(data, [
                    for (final term in terms)
                      if (selected.contains(term.id))
                        (term: term, group: group),
                  ]),
                ),
          children: [
            if (terms.isEmpty)
              StateMessage(
                icon: group?.glyph ?? AppIcons.vocabulary,
                accent: group?.accent ?? AppAccent.violet,
                title: context.l10n.groupEmptyTitle,
                message: context.l10n.groupEmptyMessage,
              )
            else ...[
              if (filtered)
                SegmentedControl(
                  options: [
                    for (final status in GroupController.filters)
                      switch (status) {
                        final status? => context.l10n.termStatus(status.name),
                        null => context.l10n.allCount(terms.length),
                      },
                  ],
                  selected: controller.filter,
                  onChanged: controller.showFilter,
                ),
              for (final term in visible)
                TermTile(
                  term: term,
                  selecting: selected != null,
                  selected: selected?.contains(term.id) ?? false,
                  onTap: selected == null
                      ? () => TermPage.open(context, term)
                      : () => controller.toggle(term.id),
                  onLongPress: selected == null
                      ? () => controller.select({term.id})
                      : null,
                ),
            ],
          ],
        ),
      );
    });
  }

  static String _meta(
    AppLocalizations l10n,
    List<Term> terms,
    TermGroup? group,
    Set<String>? selected,
  ) => switch (selected?.length) {
    final int n => l10n.selectionMeta(n),
    null when group == null || terms.isEmpty => l10n.noTermsYet,
    null => l10n.termCountMastered(terms.length, group.masteredCount),
  };
}
