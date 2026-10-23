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
  });

  final Widget header;
  final List<Widget> children;

  final double gap;

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
                  child: ListView.separated(
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
          ],
        ),
      ),
    );
  }
}
