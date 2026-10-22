import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class AppTabItem {
  const AppTabItem({required this.icon, required this.label, this.badge = 0});

  final IconData icon;
  final String label;

  /// 0 = sem badge.
  final int badge;
}

/// Tab bar inferior. `centerGap` abre espaço no meio para o botão de captura.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.centerGap = 0,
  });

  /// Altura sem a área segura inferior.
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
              // Stack do tamanho da pílula: ícone no centro, badge no canto.
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(item.icon, size: 22, color: fg),
                  if (item.badge > 0)
                    Positioned(
                      top: -3,
                      right: 8,
                      child: _Badge(count: item.badge),
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

/// Contador em alert com anel da cor da tab bar, que separa do ícone.
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 18,
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.alert,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.surface, width: 2),
      ),
      child: Text(
        '$count',
        style: AppText.tag.copyWith(letterSpacing: 0, color: c.onAlert),
      ),
    );
  }
}
