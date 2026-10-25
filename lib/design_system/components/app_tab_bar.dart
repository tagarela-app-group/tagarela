import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_badge.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class AppTabItem {
  const AppTabItem({required this.icon, required this.label, this.badge = 0});

  final IconData icon;
  final String label;

  final int badge;
}

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.centerGap = 0,
  });

  static const height = 64.0;

  final List<AppTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double centerGap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tabs = <Widget>[
      for (final (i, item) in items.indexed)
        Expanded(
          child: _Tab(
            item: item,
            selected: i == currentIndex,
            onTap: () => onTap(i),
          ),
        ),
    ];
    if (centerGap > 0) {
      tabs.insert(tabs.length ~/ 2, SizedBox(width: centerGap));
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Row(children: tabs),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.onTap});

  final AppTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.primaryText : c.inkSoft;

    return Semantics(
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSpacing.s1,
          children: [
            AnimatedContainer(
              duration: AppMotion.base,
              curve: AppMotion.standard,
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? c.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(item.icon, size: 22, color: fg),
                  if (item.badge > 0)
                    Positioned(
                      top: -3,
                      right: 8,
                      child: AppBadge(
                        label: '${item.badge}',
                        tone: AppBadgeTone.alert,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              item.label,
              style: AppText.caption.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
