import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class SheetPage extends StatelessWidget {
  const SheetPage({
    super.key,
    required this.header,
    required this.children,
    this.gap = AppSpacing.s5,
    this.onRefresh,
  });

  final Widget header;
  final List<Widget> children;

  final double gap;

  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: c.header,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.s4,
                  AppSpacing.screen,
                  AppSpacing.s6,
                ),
                child: header,
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sheet),
                ),
                child: ColoredBox(
                  color: c.bg,
                  child: _refreshable(
                    ListView.separated(
                      physics: onRefresh == null
                          ? null
                          : const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.s6,
                        AppSpacing.screen,
                        AppSpacing.s6 + bottom,
                      ),
                      itemCount: children.length,
                      separatorBuilder: (_, _) => SizedBox(height: gap),
                      itemBuilder: (_, i) => children[i],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _refreshable(Widget list) {
    final refresh = onRefresh;
    return refresh == null
        ? list
        : RefreshIndicator(onRefresh: refresh, child: list);
  }
}
