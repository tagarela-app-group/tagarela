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
    this.disabled = const {},
  });

  final List<String> options;
  final int? selected;
  final ValueChanged<int> onChanged;
  final Set<int> disabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.slow;
    final current = selected;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s1),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gaps = AppSpacing.s1 * (options.length - 1);
          final width = (constraints.maxWidth - gaps) / options.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: duration,
                curve: AppMotion.smooth,
                start: (current ?? 0) * (width + AppSpacing.s1),
                top: 0,
                bottom: 0,
                width: width,
                child: AnimatedOpacity(
                  duration: duration,
                  opacity: current == null ? 0 : 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: c.cardShadow,
                    ),
                  ),
                ),
              ),
              Row(
                spacing: AppSpacing.s1,
                children: [
                  for (final (i, label) in options.indexed)
                    Expanded(
                      child: Semantics(
                        selected: i == current,
                        button: true,
                        enabled: !disabled.contains(i),
                        child: InkWell(
                          onTap: disabled.contains(i)
                              ? null
                              : () => onChanged(i),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: SizedBox(
                            height: 40,
                            child: Center(
                              child: AnimatedOpacity(
                                duration: duration,
                                opacity: disabled.contains(i) ? 0.38 : 1,
                                child: AnimatedDefaultTextStyle(
                                  duration: duration,
                                  curve: AppMotion.smooth,
                                  style: AppText.bodyMd.copyWith(
                                    fontWeight: i == current
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: i == current ? c.ink : c.inkSoft,
                                    decoration: disabled.contains(i)
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
            ],
          );
        },
      ),
    );
  }
}
