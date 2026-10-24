import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/group_page.dart';
import 'package:tagarela/features/vocabulary/widgets/group_card.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vocabulary = AppScope.of(context).vocabulary;

    return ListenableBuilder(
      listenable: vocabulary,
      builder: (context, _) {
        final groups = vocabulary.data;
        return SheetPage(
          header: PageHeader(
            title: 'Vocabulário',
            subtitle: groups == null || groups.isEmpty
                ? null
                : '${groups.termCount} termos em ${groups.length} grupos',
            trailing: AppIconButton(
              icon: AppIcons.newGroup,
              tooltip: 'Novo grupo',
              onPressed: () {},
              variant: AppIconButtonVariant.onHeader,
            ),
          ),
          gap: AppSpacing.s4,
          centerLast: groups == null || groups.isEmpty,
          children: switch (groups) {
            null => [
              AsyncStatus(error: vocabulary.error, onRetry: vocabulary.load),
            ],
            [] => const [
              StateMessage(
                icon: AppIcons.vocabulary,
                title: 'Nenhum termo ainda',
                message: 'Capture e confirme a análise pra começar.',
              ),
            ],
            _ => [
              const SectionHeader(title: 'Seus grupos'),
              _GroupGrid(groups: groups),
            ],
          },
        );
      },
    );
  }
}

class _GroupGrid extends StatelessWidget {
  const _GroupGrid({required this.groups});

  final List<TermGroup> groups;

  void _open(BuildContext context, TermGroup group) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => GroupPage(group: group)));

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
                    child: GroupCard(
                      group: group,
                      onTap: () => _open(context, group),
                    ),
                  ),
                if (i + 1 == groups.length) const Spacer(),
              ],
            ),
          ),
      ],
    );
  }
}
