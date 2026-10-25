import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_tab_bar.dart';
import 'package:tagarela/design_system/components/arc_menu.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

abstract final class AppToast {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool aboveTabBar = false,
    Duration duration = AppMotion.toast,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          persist: true,
          margin: EdgeInsets.fromLTRB(
            AppSpacing.s4,
            0,
            AppSpacing.s4,
            (aboveTabBar ? AppTabBar.height + ArcMenu.overhang : 0) +
                AppSpacing.s4,
          ),
          content: Row(
            spacing: AppSpacing.s3,
            children: [
              _Countdown(duration: duration),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.button),
                    Text(
                      message,
                      style: AppText.label.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown({required this.duration});

  final Duration duration;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox.square(
      dimension: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CircularProgressIndicator(
                  value: 1 - _controller.value,
                  strokeWidth: 2,
                  color: c.mastered,
                ),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.mastered,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.check,
              size: 18,
              color: AppPalette.white,
            ),
          ),
        ],
      ),
    );
  }
}
