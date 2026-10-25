import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/widgets/group_card.dart';
import 'package:tagarela/features/vocabulary/widgets/group_sheet.dart';
import 'package:tagarela/l10n/l10n.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  static Future<void> _open(BuildContext context, GroupPage page) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final deleted = await Navigator.of(
      context,
    ).push<TermGroup>(MaterialPageRoute(builder: (_) => page));
    if (deleted == null || !context.mounted) return;
    final count = deleted.terms.length;
    AppToast.show(
      context,
      title: context.l10n.groupDeleted,
      message: context.l10n.groupDeletedMessage(count, deleted.name),
      actionLabel: count == 0 ? null : context.l10n.see,
      onAction: () => _open(context, const GroupPage.ungrouped()),
      aboveTabBar: true,
    );
  }

  static Future<void> _newGroup(BuildContext context) async {
    final group = await AppSheet.show<TermGroup>(
      context,
      (_) => const GroupSheet(),
    );
    if (group == null || !context.mounted) return;
    AppToast.show(
      context,
      title: context.l10n.groupCreated,
      message: context.l10n.groupCreatedMessage(group.name),
      actionLabel: context.l10n.open,
      onAction: () => _open(context, GroupPage(groupId: group.id)),
      aboveTabBar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocabulary = AppScope.of(context).vocabulary;

    return ListenableBuilder(
      listenable: vocabulary,
      builder: (context, _) {
        final data = vocabulary.data;
        final empty = data == null || data.isEmpty;
        return SheetPage(
          header: PageHeader(
            title: context.l10n.tabVocabulary,
            subtitle: empty ? null : _subtitle(context.l10n, data),
            trailing: AppIconButton(
              icon: AppIcons.newGroup,
              tooltip: context.l10n.newGroup,
              onPressed: () => _newGroup(context),
              variant: AppIconButtonVariant.onHeader,
            ),
          ),
          gap: AppSpacing.s4,
          onRefresh: vocabulary.load,
          centerLast: empty,
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
              if (data.ungrouped.isNotEmpty)
                OptionRow(
                  icon: AppIcons.ungrouped,
                  accent: AppAccent.violet,
                  title: context.l10n.ungrouped,
                  subtitle: context.l10n.termsToGroup(data.ungrouped.length),
                  dashed: true,
                  color: context.colors.surface,
                  trailing: Text(
                    context.l10n.organize,
                    style: AppText.button.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                  onTap: () => _open(context, const GroupPage.ungrouped()),
                ),
              if (data.groups.isEmpty)
                StateMessage(
                  icon: AppIcons.newGroup,
                  title: context.l10n.noGroupsYet,
                  message: context.l10n.noGroupsYetMessage,
                  actionLabel: context.l10n.createGroup,
                  onAction: () => _newGroup(context),
                )
              else ...[
                SectionHeader(title: context.l10n.yourGroups),
                _GroupGrid(
                  groups: data.groups,
                  onOpen: (group) =>
                      _open(context, GroupPage(groupId: group.id)),
                ),
              ],
            ],
          },
        );
      },
    );
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
