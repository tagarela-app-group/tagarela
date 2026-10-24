import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

typedef IconChoice = ({IconData icon, String label});

class IconPicker extends StatefulWidget {
  const IconPicker({
    super.key,
    required this.icons,
    required this.selected,
    required this.accent,
    required this.onChanged,
    this.label = 'Ícone',
  });

  static const perPage = 12;
  static const columns = 6;

  final List<IconChoice> icons;
  final int selected;
  final AppAccent accent;
  final ValueChanged<int> onChanged;
  final String label;

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  late var _page = widget.selected ~/ IconPicker.perPage;

  int get _pages => (widget.icons.length / IconPicker.perPage).ceil();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final start = _page * IconPicker.perPage;
    final end = (start + IconPicker.perPage).clamp(0, widget.icons.length);
    final hasNext = _page < _pages - 1;
    final pageLabel = '${_page + 1}/$_pages';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: AppSpacing.s2,
          children: [
            Expanded(child: Text(widget.label, style: AppText.label)),
            if (_page > 0)
              _PageButton(
                label: 'Voltar',
                icon: AppIcons.back,
                onTap: () => setState(() => _page--),
              ),
            Semantics(
              label: 'Página $pageLabel dos ícones',
              excludeSemantics: true,
              child: Text(
                pageLabel,
                style: AppText.label.copyWith(
                  color: c.inkSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Visibility(
              visible: hasNext,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: _PageButton(
                label: 'Avançar',
                icon: AppIcons.forward,
                trailingIcon: true,
                onTap: hasNext ? () => setState(() => _page++) : null,
              ),
            ),
          ],
        ),
        Column(
          spacing: AppSpacing.s2,
          children: [
            for (var row = start; row < end; row += IconPicker.columns)
              Row(
                spacing: AppSpacing.s2,
                children: [
                  for (var i = row; i < row + IconPicker.columns; i++)
                    Expanded(
                      child: i < end
                          ? _IconCell(
                              choice: widget.icons[i],
                              accent: widget.accent,
                              selected: i == widget.selected,
                              onTap: () => widget.onChanged(i),
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.trailingIcon = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool trailingIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final glyph = Icon(icon, size: 16, color: c.primaryText);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              if (!trailingIcon) glyph,
              Text(label, style: AppText.label.copyWith(color: c.primaryText)),
              if (trailingIcon) glyph,
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.choice,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final IconChoice choice;
  final AppAccent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = c.accent(accent);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: BorderSide(
        color: selected ? tint.fg : Colors.transparent,
        width: 2,
      ),
    );
    return Semantics(
      label: choice.label,
      button: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      excludeSemantics: true,
      child: Material(
        color: selected ? tint.soft : c.surfaceAlt,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: SizedBox(
            height: 48,
            child: Icon(
              choice.icon,
              size: 22,
              color: selected ? tint.fg : c.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}
