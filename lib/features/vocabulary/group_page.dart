import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, required this.group});

  final TermGroup group;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  /// Opções do filtro, na ordem do `SegmentedControl`. `null` = todos.
  static const _filters = [null, TermStatus.learning, TermStatus.mastered];

  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final terms = group.termsWith(_filters[_filter]);

    return SheetPage(
      header: _GroupHeader(group: group),
      gap: AppSpacing.s3,
      children: [
        SegmentedControl(
          options: [
            for (final status in _filters)
              status?.label ?? 'Todos · ${group.terms.length}',
          ],
          selected: _filter,
          onChanged: (i) => setState(() => _filter = i),
        ),
        for (final term in terms) TermTile(term: term),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final TermGroup group;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mastered = group.masteredCount;
    final learning = group.terms.length - mastered;

    return Column(
      spacing: 14,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppIconButton(
              icon: AppIcons.back,
              tooltip: 'Voltar',
              onPressed: () => Navigator.of(context).pop(),
              variant: AppIconButtonVariant.onHeader,
            ),
            AppIconButton(
              icon: AppIcons.more,
              tooltip: 'Mais opções',
              onPressed: () {},
              variant: AppIconButtonVariant.onHeader,
            ),
          ],
        ),
        PageHeader(
          title: group.name,
          subtitle: '${group.terms.length} termos · $mastered dominados',
          leading: AppBubble(
            size: 52,
            color: AppPalette.white,
            foreground: c.header,
            child: Icon(group.icon),
          ),
        ),
        SegmentBar(
          gap: 3,
          semanticLabel: '$learning aprendendo, $mastered dominados',
          segments: [
            Segment(learning, AppPalette.mango),
            Segment(mastered, AppPalette.mint),
          ],
        ),
      ],
    );
  }
}
