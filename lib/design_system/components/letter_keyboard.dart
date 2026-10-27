import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/status_pill.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class KeyboardAction {
  const KeyboardAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tone = StatusTone.neutral,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final StatusTone tone;
}

class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({
    super.key,
    required this.rows,
    required this.onLetter,
    required this.onBackspace,
    required this.backspaceLabel,
    required this.letterLabel,
    this.action,
  });

  static const keyHeight = 48.0;
  static const gap = 6.0;

  final List<String> rows;
  final ValueChanged<String> onLetter;
  final VoidCallback onBackspace;
  final String backspaceLabel;
  final String Function(String letter) letterLabel;
  final KeyboardAction? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final last = rows.length - 1;
        double fit(int units, int items) => (width - gap * (items - 1)) / units;
        final key = [
          fit(10, 10),
          for (final (index, row) in rows.indexed)
            index == last
                ? fit(row.length + 3, row.length + 2)
                : fit(row.length, row.length),
        ].reduce(math.min);
        final wide = key * 1.5;
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            for (final (index, row) in rows.indexed)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: gap,
                children: [
                  if (index == rows.length - 1)
                    _ActionKey(
                      width: wide,
                      icon: action?.icon,
                      label: action?.label,
                      tone: action?.tone ?? StatusTone.neutral,
                      onPressed: action?.onPressed,
                    ),
                  for (final letter in row.split(''))
                    _LetterKey(
                      width: key,
                      letter: letter,
                      label: letterLabel(letter),
                      onPressed: () => onLetter(letter),
                    ),
                  if (index == rows.length - 1)
                    _ActionKey(
                      width: wide,
                      icon: AppIcons.backspace,
                      label: backspaceLabel,
                      tone: StatusTone.neutral,
                      onPressed: onBackspace,
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _LetterKey extends StatelessWidget {
  const _LetterKey({
    required this.width,
    required this.letter,
    required this.label,
    required this.onPressed,
  });

  final double width;
  final String letter;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: _KeyFace(
        width: width,
        color: c.surfaceAlt,
        onPressed: onPressed,
        child: Text(
          letter,
          style: AppText.bodyLg.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: c.ink,
          ),
        ),
      ),
    );
  }
}

class _ActionKey extends StatelessWidget {
  const _ActionKey({
    required this.width,
    required this.icon,
    required this.label,
    required this.tone,
    required this.onPressed,
  });

  final double width;
  final IconData? icon;
  final String? label;
  final StatusTone tone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final icon = this.icon;
    if (icon == null) return SizedBox(width: width);
    final (bg, fg) = switch (tone) {
      StatusTone.learning => (c.learningSoft, c.learningText),
      StatusTone.mastered => (c.masteredSoft, c.masteredText),
      StatusTone.primary => (c.primarySoft, c.primaryText),
      StatusTone.neutral => (c.line, c.ink),
      StatusTone.alert => (
        c.accent(AppAccent.coral).soft,
        c.accent(AppAccent.coral).fg,
      ),
    };
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: _KeyFace(
        width: width,
        color: bg,
        onPressed: onPressed,
        child: Icon(icon, size: 22, color: fg),
      ),
    );
  }
}

class _KeyFace extends StatelessWidget {
  const _KeyFace({
    required this.width,
    required this.color,
    required this.onPressed,
    required this.child,
  });

  final double width;
  final Color color;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.sm);
    return Opacity(
      opacity: onPressed == null ? AppOpacity.obscured : 1,
      child: Material(
        color: color,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: SizedBox(
            width: width,
            height: LetterKeyboard.keyHeight,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
