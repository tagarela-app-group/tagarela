import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/count_label.dart';

typedef MoveTarget = ({TermGroup? group});

class MoveSheet extends StatelessWidget {
  const MoveSheet({
    super.key,
    required this.groups,
    required this.count,
    required this.from,
  });

  final List<TermGroup> groups;
  final int count;
  final String from;

  @override
  Widget build(BuildContext context) {
    void pick(TermGroup? group) =>
        Navigator.pop<MoveTarget>(context, (group: group));

    return AppSheet(
      title: 'Mover pra qual grupo?',
      subtitle: '${termsLabel(count)} de $from',
      child: groups.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StateMessage(
                  icon: AppIcons.newGroup,
                  title: 'Você ainda não tem grupos',
                  message: 'Crie um grupo pra guardar esses termos.',
                ),
                AppButton(
                  label: 'Criar grupo',
                  expand: true,
                  onPressed: () => pick(null),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s2,
              children: [
                OptionRow(
                  icon: AppIcons.add,
                  accent: AppAccent.violet,
                  title: 'Novo grupo',
                  dashed: true,
                  trailing: const SizedBox.shrink(),
                  onTap: () => pick(null),
                ),
                for (final group in groups)
                  OptionRow(
                    icon: group.icon,
                    accent: group.accent,
                    title: group.name,
                    subtitle: group.terms.isEmpty
                        ? 'Sem termos ainda'
                        : termsLabel(group.terms.length),
                    onTap: () => pick(group),
                  ),
              ],
            ),
    );
  }
}
