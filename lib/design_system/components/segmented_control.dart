import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s1),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        spacing: AppSpacing.s1,
        children: [
          for (final (i, label) in options.indexed)
            Expanded(
              child: Semantics(
                selected: i == selected,
                button: true,
                child: AnimatedContainer(
                  duration: AppMotion.base,
                  curve: AppMotion.standard,
                  decoration: BoxDecoration(
                    color: i == selected ? c.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: i == selected ? c.cardShadow : null,
                  ),
                  child: InkWell(
                    onTap: () => onChanged(i),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodyMd.copyWith(
                            fontWeight: i == selected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: i == selected ? c.ink : c.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
