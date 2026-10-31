import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class GroupHeader extends StatelessWidget {
  const GroupHeader({
    super.key,
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
