import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/count_label.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/widgets/group_card.dart';
import 'package:tagarela/features/vocabulary/widgets/group_sheet.dart';

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
      title: 'Grupo apagado',
      message: switch (count) {
        0 => '${deleted.name} saiu da lista.',
        1 => 'O termo foi pra Sem grupo.',
        _ => 'Os $count termos foram pra Sem grupo.',
      },
      actionLabel: count == 0 ? null : 'Ver',
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
      title: 'Grupo criado',
      message: '${group.name} está no topo da lista.',
      actionLabel: 'Abrir',
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
            title: 'Vocabulário',
            subtitle: empty ? null : _subtitle(data),
            trailing: AppIconButton(
              icon: AppIcons.newGroup,
              tooltip: 'Novo grupo',
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
            Vocabulary(isEmpty: true) => const [
              StateMessage(
                icon: AppIcons.vocabulary,
                title: 'Nenhum termo ainda',
                message: 'Capture e confirme a análise pra começar.',
              ),
            ],
            _ => [
              if (data.ungrouped.isNotEmpty)
                OptionRow(
                  icon: AppIcons.ungrouped,
                  accent: AppAccent.violet,
                  title: 'Sem grupo',
                  subtitle:
                      '${termsLabel(data.ungrouped.length)} pra pôr num grupo',
                  dashed: true,
                  color: context.colors.surface,
                  trailing: Text(
                    'Organizar',
                    style: AppText.button.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                  onTap: () => _open(context, const GroupPage.ungrouped()),
                ),
              if (data.groups.isEmpty)
                StateMessage(
                  icon: AppIcons.newGroup,
                  title: 'Nenhum grupo ainda',
                  message: 'Crie um grupo pra organizar seus termos.',
                  actionLabel: 'Criar grupo',
                  onAction: () => _newGroup(context),
                )
              else ...[
                const SectionHeader(title: 'Seus grupos'),
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

  static String _subtitle(Vocabulary data) => data.groups.isEmpty
      ? termsLabel(data.termCount)
      : '${termsLabel(data.termCount)} em ${groupsLabel(data.groups.length)}';
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
