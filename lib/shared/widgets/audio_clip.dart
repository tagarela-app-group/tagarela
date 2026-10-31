import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class AudioClip extends StatefulWidget {
  const AudioClip({super.key, required this.file});

  final File file;

  @override
  State<AudioClip> createState() => _AudioClipState();
}

class _AudioClipState extends State<AudioClip> {
  static const _bars = [
    8,
    14,
    22,
    12,
    26,
    30,
    18,
    10,
    24,
    32,
    20,
    14,
    8,
    16,
    28,
    22,
    12,
    6,
    14,
    24,
    16,
    10,
    6,
    10,
    6,
  ];

  late final _playback = AppScope.of(context).playback;
  late final _duration = _playback.duration(widget.file);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s25,
        AppSpacing.s25,
        AppSpacing.s35,
        AppSpacing.s25,
      ),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListenableBuilder(
        listenable: _playback,
        builder: (context, _) {
          final playing = _playback.playing == widget.file.path;
          final total = _playback.total;
          final progress = playing && total != null && total > Duration.zero
              ? _playback.position.inMilliseconds / total.inMilliseconds
              : 0.0;
          return Row(
            spacing: AppSpacing.s3,
            children: [
              AppIconButton(
                icon: playing ? AppIcons.stop : AppIcons.play,
                tooltip: playing
                    ? context.l10n.stop
                    : context.l10n.listenRecording,
                onPressed: () => _playback.toggle(widget.file),
                variant: AppIconButtonVariant.primary,
                size: AppBubbleSize.md,
              ),
              Expanded(
                child: ExcludeSemantics(
                  child: SizedBox(
                    height: 32,
                    child: ClipRect(
                      child: Row(
                        spacing: AppSpacing.s075,
                        children: [
                          for (final (i, h) in _bars.indexed)
                            Container(
                              width: 3,
                              height: h.toDouble(),
                              decoration: BoxDecoration(
                                color: !playing || i / _bars.length < progress
                                    ? c.primaryText
                                    : c.line,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xxs,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              FutureBuilder(
                future: _duration,
                builder: (context, snapshot) => Text(
                  clockLabel(playing ? total : snapshot.data),
                  style: AppText.label.copyWith(
                    color: c.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String clockLabel(Duration? duration) {
  if (duration == null) return '–:––';
  final seconds = duration.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}
