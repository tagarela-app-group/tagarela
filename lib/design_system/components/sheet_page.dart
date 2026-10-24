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
    this.footer,
    this.centerLast = false,
  });

  final Widget header;
  final List<Widget> children;

  final double gap;

  final bool centerLast;

  final RefreshCallback? onRefresh;

  final Widget? footer;

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
                    _body(
                      EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.s6,
                        AppSpacing.screen,
                        AppSpacing.s6 + (footer == null ? bottom : 0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (footer case final footer?)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.bg,
                  border: Border(top: BorderSide(color: c.line)),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.s3,
                    AppSpacing.screen,
                    AppSpacing.s3 + bottom,
                  ),
                  child: footer,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _body(EdgeInsets padding) {
    final physics = onRefresh == null
        ? null
        : const AlwaysScrollableScrollPhysics();
    if (!centerLast || children.isEmpty) {
      return ListView.separated(
        physics: physics,
        padding: padding,
        itemCount: children.length,
        separatorBuilder: (_, _) => SizedBox(height: gap),
        itemBuilder: (_, i) => children[i],
      );
    }
    final above = children.sublist(0, children.length - 1);
    return CustomScrollView(
      physics: physics,
      slivers: [
        if (above.isNotEmpty)
          SliverPadding(
            padding: padding.copyWith(bottom: gap),
            sliver: SliverList.separated(
              itemCount: above.length,
              separatorBuilder: (_, _) => SizedBox(height: gap),
              itemBuilder: (_, i) => above[i],
            ),
          ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: above.isEmpty ? padding : padding.copyWith(top: 0),
            child: Center(child: children.last),
          ),
        ),
      ],
    );
  }

  Widget _refreshable(Widget list) {
    final refresh = onRefresh;
    return refresh == null
        ? list
        : RefreshIndicator(onRefresh: refresh, child: list);
  }
}
