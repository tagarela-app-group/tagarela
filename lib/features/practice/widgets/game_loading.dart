import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class GameLoading extends StatefulWidget {
  const GameLoading({super.key, required this.onLeave});

  static const _lines = ['a', 'b', 'c', 'd', 'e', 'f'];

  final VoidCallback onLeave;

  @override
  State<GameLoading> createState() => _GameLoadingState();
}

class _GameLoadingState extends State<GameLoading> {
  var _line = 0;
  var _late = false;
  late final Timer _roll;
  late final Timer _patience;

  @override
  void initState() {
    super.initState();
    _roll = Timer.periodic(AppMotion.rollEvery, (_) => setState(() => _line++));
    _patience = Timer(
      AppMotion.loadingPatience,
      () => setState(() => _late = true),
    );
  }

  @override
  void dispose() {
    _roll.cancel();
    _patience.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          Semantics(
            label: l10n.practiceLoading,
            liveRegion: true,
            child: ExcludeSemantics(
              child: RollingText(
                texts: [
                  for (final line in GameLoading._lines) l10n.loadingLine(line),
                ],
                index: _line,
                maxLines: 2,
                alignment: AlignmentDirectional.bottomCenter,
                textAlign: TextAlign.center,
                style: AppText.titleLg.copyWith(color: AppPalette.white),
              ),
            ),
          ),
          const Center(child: TypingDots(color: AppPalette.white)),
          Center(
            child: Visibility(
              visible: _late,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: AppButton(
                label: l10n.practiceLeave,
                variant: AppButtonVariant.onHeader,
                size: AppButtonSize.small,
                onPressed: widget.onLeave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
