import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    this.rows = const [],
    this.child,
  });

  final String title;
  final List<ProfileRow> rows;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s3,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s2),
          child: Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: AppText.overline.copyWith(color: c.inkSoft),
            ),
          ),
        ),
        child ??
            AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s1,
              ),
              child: Column(
                children: [
                  for (final (i, row) in rows.indexed) ...[
                    if (i > 0) Divider(height: 1, thickness: 1, color: c.line),
                    row,
                  ],
                ],
              ),
            ),
      ],
    );
  }
}

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    this.icon,
    this.accent = AppAccent.violet,
    this.leading,
    required this.title,
    required this.text,
    this.trailing,
    this.onTap,
  });

  final IconData? icon;
  final AppAccent accent;
  final Widget? leading;
  final String title;
  final String text;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
      child: Row(
        spacing: AppSpacing.s3,
        children: [
          leading ?? IconTile(icon: icon, accent: accent, size: 40),
          Expanded(
            child: TitledText(title: title, text: text),
          ),
          ?(trailing ??
              (onTap == null
                  ? null
                  : Icon(AppIcons.forward, size: 20, color: c.inkSoft))),
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}
