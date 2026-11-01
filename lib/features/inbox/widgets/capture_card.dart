import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/logic/term_selection.dart';
import 'package:tagarela/features/inbox/widgets/capture_actions.dart';
import 'package:tagarela/features/inbox/widgets/capture_content.dart';
import 'package:tagarela/features/inbox/widgets/capture_failure.dart';
import 'package:tagarela/features/inbox/widgets/capture_missing_media.dart';
import 'package:tagarela/features/inbox/widgets/capture_processing.dart';
import 'package:tagarela/features/inbox/widgets/capture_terms.dart';
import 'package:tagarela/features/inbox/widgets/capture_thumbnail.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/capture_style.dart';
import 'package:tagarela/shared/logic/time_ago.dart';
import 'package:tagarela/shared/widgets/audio_clip.dart';

class CaptureCard extends StatefulWidget {
  const CaptureCard({
    super.key,
    required this.capture,
    required this.now,
    this.onDiscard,
    this.onProcess,
    this.onPick,
    this.onConfirm,
  });

  final Capture capture;
  final DateTime now;
  final VoidCallback? onDiscard;
  final VoidCallback? onProcess;
  final VoidCallback? onPick;
  final VoidCallback? onConfirm;

  @override
  State<CaptureCard> createState() => _CaptureCardState();
}

class _CaptureCardState extends State<CaptureCard> {
  late Future<File?> _media = _findMedia();

  Future<File?> _findMedia() =>
      AppScope.of(context).captures.mediaFile(widget.capture);

  @override
  void didUpdateWidget(CaptureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.capture.mediaPath != widget.capture.mediaPath) {
      _media = _findMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    final capture = widget.capture;
    return AppCard(
      child: FutureBuilder(
        future: _media,
        builder: (context, snapshot) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s3,
          children: [
            _Header(capture: capture, now: widget.now),
            ..._body(
              capture,
              snapshot.data,
              loaded: snapshot.connectionState == ConnectionState.done,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(Capture capture, File? media, {required bool loaded}) {
    Widget withMedia(Widget child, {bool audio = true}) =>
        switch (capture.source) {
          CaptureSource.photo => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s3,
            children: [
              CaptureThumbnail(file: media),
              Expanded(child: child),
            ],
          ),
          CaptureSource.audio when audio && media != null => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s3,
            children: [
              AudioClip(file: media),
              child,
            ],
          ),
          _ => child,
        };

    return switch (capture.status) {
      CaptureStatus.failed => [
        withMedia(captureFailure(context.l10n, capture)),
        CaptureActions(
          secondary: (context.l10n.discard, widget.onDiscard),
          primary: (
            capture.refused ? context.l10n.tryAgain : context.l10n.processNow,
            widget.onProcess,
          ),
        ),
      ],
      CaptureStatus.ready => [
        withMedia(CaptureContent(capture: capture), audio: false),
        if (capture.source != CaptureSource.text && loaded && media == null)
          CaptureMissingMedia(capture.source),
        if (capture.terms.isNotEmpty) CaptureTerms(terms: capture.terms),
        if (TermSelection.forPicking(capture).spans.isEmpty)
          CaptureActions(
            secondary: (context.l10n.discard, widget.onDiscard),
            primary: widget.onPick == null
                ? null
                : (context.l10n.pick, widget.onPick),
          )
        else
          CaptureActions(
            secondary: widget.onPick == null
                ? null
                : (context.l10n.edit, widget.onPick),
            primary: (context.l10n.confirmAnalysis, widget.onConfirm),
          ),
      ],
      CaptureStatus.processing => [
        withMedia(CaptureProcessing(source: capture.source)),
      ],
      CaptureStatus.analyzed => const [],
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.capture, required this.now});

  final Capture capture;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final tone = switch (capture.status) {
      CaptureStatus.failed => StatusTone.alert,
      CaptureStatus.ready => StatusTone.primary,
      CaptureStatus.processing => StatusTone.learning,
      CaptureStatus.analyzed => StatusTone.neutral,
    };
    final l10n = context.l10n;
    return Row(
      spacing: AppSpacing.s2,
      children: [
        IconTile(
          icon: capture.source.glyph,
          accent: capture.source.accent,
          size: AppBubbleSize.xs,
        ),
        Expanded(
          child: Text(
            '${l10n.captureSource(capture.source.name)} · '
            '${timeAgo(l10n, capture.capturedAt, now)}',
            style: AppText.label.copyWith(color: context.colors.inkSoft),
          ),
        ),
        StatusPill(label: l10n.captureStatus(capture.status.name), tone: tone),
      ],
    );
  }
}
