import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/device/text_extractor.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/capture_style.dart';
import 'package:tagarela/shared/logic/time_ago.dart';
import 'package:tagarela/shared/widgets/audio_clip.dart';

typedef CardAction = (String label, VoidCallback? onPressed);

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
    final hasMedia = capture.source != CaptureSource.text;
    Widget withMedia(Widget child, {bool audio = true}) =>
        switch (capture.source) {
          CaptureSource.photo => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s3,
            children: [
              _Thumbnail(file: media),
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
        withMedia(_failure(context.l10n, capture)),
        _Actions(
          secondary: (context.l10n.discard, widget.onDiscard),
          primary: (context.l10n.processNow, widget.onProcess),
        ),
      ],
      CaptureStatus.ready => [
        withMedia(
          _Content(capture: capture, clamp: capture.source.isPhoto),
          audio: false,
        ),
        if (hasMedia && loaded && media == null) _MissingMedia(capture.source),
        if (capture.terms.isNotEmpty) _Terms(terms: capture.terms),
        if (capture.terms.isEmpty)
          _Actions(
            secondary: (context.l10n.discard, widget.onDiscard),
            primary: widget.onPick == null
                ? null
                : (context.l10n.pickTerms, widget.onPick),
          )
        else
          _Actions(
            secondary: widget.onPick == null
                ? null
                : (context.l10n.edit, widget.onPick),
            primary: (context.l10n.confirmAnalysis, widget.onConfirm),
          ),
      ],
      CaptureStatus.processing => [
        withMedia(
          capture.source.isPhoto
              ? _StatusLine(
                  icon: AppIcons.review,
                  text: context.l10n.readingPhoto,
                )
              : const _Transcribing(),
        ),
      ],
      CaptureStatus.analyzed => const [],
    };
  }
}

TitledText _failure(
  AppLocalizations l10n,
  Capture capture,
) => switch (capture.error) {
  final e when e == ExtractionError.noText.code => TitledText(
    title: capture.source.isPhoto ? l10n.noTextInPhoto : l10n.noSpeech,
    text: capture.source.isPhoto ? l10n.noTextInPhotoHint : l10n.noSpeechHint,
  ),
  _ => TitledText(title: l10n.processFailedTitle, text: l10n.processFailedHint),
};

extension on CaptureSource {
  bool get isPhoto => this == CaptureSource.photo;
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
          size: 28,
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.file});

  final File? file;

  static const _size = 64.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final placeholder = Container(
      width: _size,
      height: _size,
      color: c.surfaceAlt,
      alignment: Alignment.center,
      child: Icon(AppIcons.camera, color: c.inkSoft),
    );
    final file = this.file;
    return Semantics(
      label: context.l10n.capturePhoto,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: file == null
            ? placeholder
            : Image.file(
                file,
                width: _size,
                height: _size,
                fit: BoxFit.cover,
                cacheWidth: (_size * 3).round(),
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.capture, required this.clamp});

  final Capture capture;
  final bool clamp;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.captureContent(capture.source.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          label,
          style: AppText.pill.copyWith(color: context.colors.inkSoft),
        ),
        Text(
          capture.text,
          style: AppText.bodyLg,
          maxLines: clamp ? 3 : null,
          overflow: clamp ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }
}

class _MissingMedia extends StatelessWidget {
  const _MissingMedia(this.source);

  final CaptureSource source;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s2,
        children: [
          Icon(AppIcons.info, size: 18, color: c.inkSoft),
          Expanded(
            child: Text(
              source.isPhoto
                  ? context.l10n.missingPhoto
                  : context.l10n.missingAudio,
              style: AppText.label.copyWith(color: c.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _Terms extends StatelessWidget {
  const _Terms({required this.terms});

  final List<CaptureTerm> terms;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chips = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [for (final term in terms) TermChip(label: term.text)],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s2,
      children: [
        Text(
          context.l10n.termsChosen(terms.length),
          style: AppText.pill.copyWith(color: c.inkSoft),
        ),
        chips,
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({this.secondary, this.primary});

  final CardAction? secondary;
  final CardAction? primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.s2,
      children: [
        if (secondary case (final label, final onPressed))
          Expanded(
            child: AppButton(
              label: label,
              onPressed: onPressed,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.small,
              expand: true,
            ),
          ),
        if (primary case (final label, final onPressed))
          Expanded(
            child: AppButton(
              label: label,
              onPressed: onPressed,
              size: AppButtonSize.small,
              expand: true,
            ),
          ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final soft = context.colors.inkSoft;
    return Row(
      spacing: AppSpacing.s2,
      children: [
        Icon(icon, size: 18, color: soft),
        Expanded(
          child: Text(text, style: AppText.bodyMd.copyWith(color: soft)),
        ),
      ],
    );
  }
}

class _Transcribing extends StatelessWidget {
  const _Transcribing();

  @override
  Widget build(BuildContext context) {
    final speech = AppScope.of(context).speech;
    return ListenableBuilder(
      listenable: speech,
      builder: (context, _) => _StatusLine(
        icon: AppIcons.review,
        text: !speech.ready
            ? context.l10n.waitingModel
            : context.l10n.transcribing,
      ),
    );
  }
}
