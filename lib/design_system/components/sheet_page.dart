import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

/// Layout padrão de tela: header colorido + body com topo arredondado.
/// O body rola e respeita `MediaQuery.padding.bottom`.
class SheetPage extends StatelessWidget {
  const SheetPage({
    super.key,
    required this.header,
    required this.children,
    this.gap = AppSpacing.s5,
  });

  final Widget header;
  final List<Widget> children;

  /// Espaço entre os itens do body.
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
