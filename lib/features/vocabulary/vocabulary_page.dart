import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/term_page.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/logic/term_actions.dart';
import 'package:tagarela/features/vocabulary/logic/term_filter.dart';
import 'package:tagarela/features/vocabulary/modals/group_modal.dart';
import 'package:tagarela/features/vocabulary/widgets/group_card.dart';
import 'package:tagarela/features/vocabulary/widgets/selection_bar.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';
import 'package:tagarela/l10n/l10n.dart';

enum VocabularyView { terms, groups }

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});

  @override
  State<VocabularyPage> createState() => VocabularyPageState();
}

class VocabularyPageState extends State<VocabularyPage> with TermActions {
  VocabularyView _view = VocabularyView.terms;
  TermFilter _filter = TermFilter.all;

  void showUngrouped() => setState(() {
    _view = VocabularyView.terms;
    _filter = TermFilter.ungrouped;
  });

  void cancelSelection() => controller.select(null);

  Future<void> _open(GroupPage page) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final deleted = await Navigator.of(
      context,
    ).push<TermGroup>(MaterialPageRoute(builder: (_) => page));
    if (deleted == null || !mounted) return;
    final count = deleted.terms.length;
    AppToast.show(
      context,
      title: context.l10n.groupDeleted,
      message: context.l10n.groupDeletedMessage(count, deleted.name),
      actionLabel: count == 0 ? null : context.l10n.see,
      onAction: showUngrouped,
      aboveTabBar: true,
    );
  }

  Future<void> _newGroup() async {
    final group = await AppModal.show<TermGroup>(
      context,
      (_) => const GroupModal(),
    );
    if (group == null || !mounted) return;
    setState(() => _view = VocabularyView.groups);
    AppToast.show(
      context,
      title: context.l10n.groupCreated,
      message: context.l10n.groupCreatedMessage(group.name),
      actionLabel: context.l10n.open,
      onAction: () => _open(GroupPage(groupId: group.id)),
      aboveTabBar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocabulary = AppScope.of(context).vocabulary;

    return listening((context) {
      final data = vocabulary.data;
      final empty = data == null || data.isEmpty;
      final selected = controller.selected;
      final entries = data?.entries ?? const <TermEntry>[];
      final visible = entries.where(_filter.accepts).toList();
      final blank = _view == VocabularyView.terms
          ? visible.isEmpty
          : data?.groups.isEmpty ?? true;

      return PopScope(
        canPop: selected == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.select(null);
        },
        child: AppPage(
          header: selected == null
              ? PageHeader(
                  title: context.l10n.tabVocabulary,
                  subtitle: empty ? null : _subtitle(context.l10n, data),
                  trailing: AppIconButton(
                    icon: AppIcons.newGroup,
                    tooltip: context.l10n.newGroup,
                    onPressed: _newGroup,
                    variant: AppIconButtonVariant.onHeader,
                  ),
                )
              : Column(
                  spacing: AppSpacing.s35,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cancelSelectionButton(),
                        selectAllButton(visible.map((e) => e.term)),
                      ],
                    ),
                    PageHeader(
                      title: context.l10n.tabVocabulary,
                      subtitle: context.l10n.selectionMeta(selected.length),
                    ),
                  ],
                ),
          gap: AppSpacing.s3,
          onRefresh: vocabulary.load,
          centerLast: empty || blank,
          footer: selected == null || data == null
              ? null
              : SelectionBar(
                  count: selected.length,
                  change: controller.change,
                  onDelete: () => deleteTerms(
                    controller.selectedIn([
                      for (final entry in entries) entry.term,
                    ]),
                  ),
                  onMove: () => pickTarget(data, [
                    for (final entry in entries)
                      if (selected.contains(entry.term.id)) entry,
                  ]),
                ),
          children: switch (data) {
            null => [
              AsyncStatus(error: vocabulary.error, onRetry: vocabulary.load),
            ],
            Vocabulary(isEmpty: true) => [
              StateMessage(
                icon: AppIcons.vocabulary,
                title: context.l10n.noTermsYet,
                message: context.l10n.vocabularyEmptyMessage,
              ),
            ],
            _ => [
              if (selected == null)
                SegmentedControl(
                  options: [
                    for (final view in VocabularyView.values)
                      context.l10n.vocabularyView(view.name),
                  ],
                  selected: _view.index,
                  onChanged: (i) =>
                      setState(() => _view = VocabularyView.values[i]),
                ),
              ...switch (_view) {
                VocabularyView.terms => _terms(data, entries, visible),
                VocabularyView.groups => _groups(data),
              },
            ],
          },
        ),
      );
    });
  }

  List<Widget> _terms(
    Vocabulary data,
    List<TermEntry> entries,
    List<TermEntry> visible,
  ) {
    final selected = controller.selected;
    return [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          spacing: AppSpacing.s2,
          children: [
            for (final filter in TermFilter.values)
              AppChip(
                label: _filterLabel(filter, entries),
                selected: _filter == filter,
                onTap: () => setState(() => _filter = filter),
              ),
          ],
        ),
      ),
      if (visible.isEmpty)
        switch (_filter) {
          TermFilter.ungrouped => StateMessage(
            icon: AppIcons.ungrouped,
            title: context.l10n.allOrganized,
            message: context.l10n.allOrganizedMessage,
          ),
          TermFilter.all => StateMessage(
            icon: AppIcons.vocabulary,
            title: context.l10n.noTermsYet,
            message: context.l10n.vocabularyEmptyMessage,
          ),
          _ => StateMessage(
            icon: AppIcons.vocabulary,
            title: context.l10n.nothingHere,
            message: context.l10n.noTermsInFilter,
          ),
        }
      else
        for (final entry in visible)
          TermTile(
            term: entry.term,
            showGroup: true,
            group: entry.group,
            onAddToGroup: () => pickTarget(data, [entry]),
            selecting: selected != null,
            selected: selected?.contains(entry.term.id) ?? false,
            onTap: selected == null
                ? () => TermPage.open(context, entry.term)
                : () => controller.toggle(entry.term.id),
            onLongPress: selected == null
                ? () => controller.select({entry.term.id})
                : null,
          ),
    ];
  }

  List<Widget> _groups(Vocabulary data) => [
    if (data.groups.isEmpty)
      StateMessage(
        icon: AppIcons.newGroup,
        title: context.l10n.noGroupsYet,
        message: context.l10n.noGroupsYetMessage,
        actionLabel: context.l10n.createGroup,
        onAction: _newGroup,
      )
    else
      _GroupGrid(
        groups: data.groups,
        onOpen: (group) => _open(GroupPage(groupId: group.id)),
      ),
  ];

  String _filterLabel(TermFilter filter, List<TermEntry> entries) {
    final l10n = context.l10n;
    return switch (filter) {
      TermFilter.all => l10n.allCount(entries.length),
      TermFilter.ungrouped =>
        '${l10n.ungrouped} · ${entries.where(filter.accepts).length}',
      TermFilter.learning ||
      TermFilter.mastered => l10n.termStatus(filter.name),
    };
  }

  static String _subtitle(AppLocalizations l10n, Vocabulary data) =>
      data.groups.isEmpty
      ? l10n.termCount(data.termCount)
      : l10n.termsInGroups(
          l10n.termCount(data.termCount),
          l10n.groupCount(data.groups.length),
        );
}

class _GroupGrid extends StatelessWidget {
  const _GroupGrid({required this.groups, required this.onOpen});

  final List<TermGroup> groups;
  final ValueChanged<TermGroup> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.s3,
      children: [
        for (var i = 0; i < groups.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s3,
              children: [
                for (final group in groups.skip(i).take(2))
                  Expanded(
                    child: GroupCard(group: group, onTap: () => onOpen(group)),
                  ),
                if (i + 1 == groups.length) const Spacer(),
              ],
            ),
          ),
      ],
    );
  }
}
