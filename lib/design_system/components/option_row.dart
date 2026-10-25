import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/icon_tile.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class OptionRow extends StatelessWidget {
  const OptionRow({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
    this.dashed = false,
    this.color,
    this.selected,
  });

  final IconData icon;
  final AppAccent accent;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  final Widget? trailing;

  final bool dashed;
  final Color? color;

  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppRadius.lg);
    final ShapeBorder shape = dashed
        ? _DashedBorder(radius: radius, color: c.primary)
        : RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: c.line, width: 1.5),
          );
    final row = Material(
      color: color ?? Colors.transparent,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s3),
          child: Row(
            spacing: AppSpacing.s3,
            children: [
              IconTile(icon: icon, accent: accent, size: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      title,
                      style: AppText.bodyLg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle case final subtitle?)
                      Text(
                        subtitle,
                        style: AppText.label.copyWith(
                          color: c.inkSoft,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  switch (selected) {
                    null => Icon(AppIcons.forward, size: 20, color: c.inkSoft),
                    true => Icon(AppIcons.check, size: 22, color: c.primary),
                    false => const SizedBox.shrink(),
                  },
            ],
          ),
        ),
      ),
    );
    return selected == null
        ? row
        : Semantics(
            selected: selected,
            inMutuallyExclusiveGroup: true,
            child: row,
          );
  }
}

class _DashedBorder extends ShapeBorder {
  const _DashedBorder({required this.radius, required this.color});

  static const _width = 1.5;
  static const _dash = 6.0;
  static const _gap = 4.0;

  final BorderRadius radius;
  final Color color;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(_width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(_width), textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(radius.toRRect(rect));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _width;
    final outline = Path()..addRRect(radius.toRRect(rect.deflate(_width / 2)));
    for (final PathMetric metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  ShapeBorder scale(double t) => this;
}
