import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class GotItCheck extends StatefulWidget {
  const GotItCheck({super.key});

  @override
  State<GotItCheck> createState() => _GotItCheckState();
}

class _GotItCheckState extends State<GotItCheck> {
  bool? _gotIt;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.slow;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s3,
        AppSpacing.s3,
        AppSpacing.s3,
      ),
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: AppMotion.spring),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: switch (_gotIt) {
          null => Column(
            key: const ValueKey('ask'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s2,
            children: [
              Text(
                l10n.gotItQuestion,
                style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w700),
              ),
              Row(
                spacing: 6,
                children: [
                  AppButton(
                    label: l10n.gotItYes,
                    variant: AppButtonVariant.tonal,
                    size: AppButtonSize.small,
                    onPressed: () => setState(() => _gotIt = true),
                  ),
                  AppButton(
                    label: l10n.gotItNo,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.small,
                    onPressed: () => setState(() => _gotIt = false),
                  ),
                ],
              ),
            ],
          ),
          final gotIt => Semantics(
            key: const ValueKey('reply'),
            liveRegion: true,
            child: SizedBox(
              height: AppButtonSize.small.height,
              child: Row(
                spacing: 10,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: SpeechBubbleIcon(size: 18, color: c.primaryText),
                  ),
                  Expanded(
                    child: Text(
                      gotIt ? l10n.gotItYesReply : l10n.gotItNoReply,
                      style: AppText.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        },
      ),
    );
  }
}
