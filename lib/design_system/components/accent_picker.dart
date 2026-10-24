import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class AccentPicker extends StatelessWidget {
  const AccentPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.label = 'Cor',
  });

  static const names = {
    AppAccent.violet: 'Violeta',
    AppAccent.coral: 'Coral',
    AppAccent.mint: 'Menta',
    AppAccent.mango: 'Manga',
    AppAccent.sky: 'Céu',
    AppAccent.pink: 'Rosa',
  };

  final AppAccent selected;
  final ValueChanged<AppAccent> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s2,
      children: [
        Text(label, style: AppText.label),
        Row(
          spacing: AppSpacing.s2,
          children: [
            for (final accent in AppAccent.values)
              Expanded(
                child: _Swatch(
                  accent: accent,
                  selected: accent == selected,
                  onTap: () => onChanged(accent),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final AppAccent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = c.accent(accent).fg;
    return Semantics(
      label: AccentPicker.names[accent],
      button: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: 48,
          child: Center(
            child: AnimatedContainer(
              duration: AppMotion.fast,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: selected
                    ? [
                        BoxShadow(color: color, spreadRadius: 5),
                        BoxShadow(color: c.surface, spreadRadius: 3),
                      ]
                    : null,
              ),
              child: selected
                  ? Icon(AppIcons.check, size: 18, color: c.surface)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
