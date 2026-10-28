import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/widgets/highlighted_text.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/capture_style.dart';
import 'package:tagarela/shared/logic/time_ago.dart';

class SeenCaptures extends StatelessWidget {
  const SeenCaptures({
    super.key,
    required this.captures,
    required this.termId,
    required this.locale,
    required this.onOpenTerm,
  });

  static const cardWidth = 272.0;

  final List<SeenCapture> captures;
  final String termId;
  final Locale locale;
  final ValueChanged<String> onOpenTerm;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.whereYouSaw,
                  style: AppText.label.copyWith(color: c.inkSoft),
                ),
              ),
            ),
            Text(
              l10n.captureCount(captures.length),
              style: AppText.label.copyWith(
                color: c.inkSoft,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        if (captures case [final capture])
          _card(capture)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                for (final capture in captures)
                  SizedBox(width: cardWidth, child: _card(capture)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _card(SeenCapture capture) => _SeenCard(
    capture: capture,
    termId: termId,
    locale: locale,
    onOpenTerm: onOpenTerm,
  );
}

class _SeenCard extends StatelessWidget {
  const _SeenCard({
    required this.capture,
    required this.termId,
    required this.locale,
    required this.onOpenTerm,
  });

  final SeenCapture capture;
  final String termId;
  final Locale locale;
  final ValueChanged<String> onOpenTerm;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final also = <String, String>{
      for (final span in capture.spans)
        if (span.termId case final id? when id != termId) id: span.text,
    };
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        14,
        AppSpacing.s4,
        AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: AppSpacing.s2,
            children: [
              IconTile(
                icon: capture.source.glyph,
                accent: capture.source.accent,
                size: 28,
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.seenVia(capture.source.name),
                        style: TextStyle(
                          color: c.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' · ${timeAgo(l10n, capture.capturedAt, DateTime.now())}',
                      ),
                    ],
                  ),
                  style: AppText.label.copyWith(
                    color: c.inkSoft,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          if (capture.source == CaptureSource.audio)
            _Recording(captureId: capture.id),
          HighlightedText(
            text: capture.text,
            ranges: [
              for (final span in capture.spans)
                if (span.termId == termId) (span.start, span.end),
            ],
            maxLines: 3,
            locale: locale,
          ),
          if (also.isNotEmpty)
            Wrap(
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.alsoMarked,
                  style: AppText.pill.copyWith(
                    color: c.inkSoft,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                for (final MapEntry(key: id, value: text) in also.entries)
                  AppChip(
                    label: text,
                    selected: false,
                    onTap: () => onOpenTerm(id),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Recording extends StatefulWidget {
  const _Recording({required this.captureId});

  final String captureId;

  @override
  State<_Recording> createState() => _RecordingState();
}

class _RecordingState extends State<_Recording> {
  late final Future<File?> _file = _find();

  Future<File?> _find() async {
    final captures = AppScope.of(context).captures;
    final local = captures.data
        ?.where((c) => c.id == widget.captureId)
        .firstOrNull;
    return local == null ? null : captures.mediaFile(local);
  }

  @override
  Widget build(BuildContext context) {
    final playback = AppScope.of(context).playback;
    return FutureBuilder(
      future: _file,
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) return const SizedBox.shrink();
        return ListenableBuilder(
          listenable: playback,
          builder: (context, _) {
            final c = context.colors;
            final playing = playback.playing == file.path;
            final total = playback.total?.inMilliseconds ?? 0;
            final progress = playing && total > 0
                ? playback.position.inMilliseconds / total
                : 0.0;
            return Row(
              spacing: 10,
              children: [
                AppIconButton(
                  icon: playing ? AppIcons.stop : AppIcons.play,
                  tooltip: playing
                      ? context.l10n.stop
                      : context.l10n.listenRecording,
                  onPressed: () => playback.toggle(file),
                  variant: AppIconButtonVariant.primary,
                ),
                Expanded(
                  child: Waveform(
                    progress: progress,
                    color: c.primary,
                    track: c.line,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
