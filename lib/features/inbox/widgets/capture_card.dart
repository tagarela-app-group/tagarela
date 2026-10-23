import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/widgets/audio_clip.dart';

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
    final muted = capture.status == CaptureStatus.analyzed;
    return AppCard(
      muted: muted,
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
        withMedia(
          const _Message(
            title: 'Não deu pra processar agora',
            text: 'Toque em Processar agora pra tentar de novo.',
          ),
        ),
        _Actions(
          secondary: ('Descartar', widget.onDiscard),
          primary: ('Processar agora', widget.onProcess),
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
            secondary: ('Descartar', widget.onDiscard),
            primary: widget.onPick == null
                ? null
                : ('Escolher termos', widget.onPick),
          )
        else
          _Actions(
            secondary: widget.onPick == null ? null : ('Editar', widget.onPick),
            primary: ('Confirmar análise', widget.onConfirm),
          ),
      ],
      CaptureStatus.processing => [
        withMedia(
          _StatusLine(
            icon: AppIcons.review,
            text: capture.source.isPhoto
                ? 'Lendo o texto da foto…'
                : 'Transcrevendo o áudio…',
          ),
        ),
      ],
      CaptureStatus.waitingFile => [
        withMedia(
          const _StatusLine(
            icon: AppIcons.offline,
            text: 'Puxe a lista pra enviar quando tiver internet.',
          ),
        ),
      ],
      CaptureStatus.analyzed => [
        Text(capture.text, style: AppText.bodyLg),
        if (capture.terms.isNotEmpty) _Terms(terms: capture.terms, muted: true),
      ],
    };
  }
}

extension on CaptureSource {
  bool get isPhoto => this == CaptureSource.photo;
}

String timeAgo(DateTime at, DateTime now) {
  final local = at.toLocal();
  final diff = now.difference(local);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inHours < 1) return 'há ${diff.inMinutes} min';
  final day = DateTime(local.year, local.month, local.day);
  if (day == DateTime(now.year, now.month, now.day)) {
    return 'há ${diff.inHours} h';
  }
  if (day == DateTime(now.year, now.month, now.day - 1)) return 'ontem';
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  return '$dd/$mm';
}

class _Header extends StatelessWidget {
  const _Header({required this.capture, required this.now});

  final Capture capture;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final (icon, accent) = switch (capture.source) {
      CaptureSource.photo => (AppIcons.camera, AppAccent.mango),
      CaptureSource.audio => (AppIcons.audio, AppAccent.coral),
      CaptureSource.text => (AppIcons.text, AppAccent.violet),
    };
    final (status, tone) = switch (capture.status) {
      CaptureStatus.failed => ('Erro', StatusTone.alert),
      CaptureStatus.ready => ('Pronta', StatusTone.primary),
      CaptureStatus.processing => ('Processando', StatusTone.learning),
      CaptureStatus.waitingFile => ('Não enviada', StatusTone.neutral),
      CaptureStatus.analyzed => ('Analisada', StatusTone.neutral),
    };
    final muted = capture.status == CaptureStatus.analyzed;

    return Row(
      spacing: AppSpacing.s2,
      children: [
        IconTile(icon: icon, accent: muted ? null : accent, size: 28),
        Expanded(
          child: Text(
            '${capture.source.label} · ${timeAgo(capture.capturedAt, now)}',
            style: AppText.label.copyWith(color: context.colors.inkSoft),
          ),
        ),
        StatusPill(label: status, tone: tone),
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
      label: 'Foto da captura',
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
    final label = switch (capture.source) {
      CaptureSource.text => 'Seu texto',
      CaptureSource.photo => 'Texto da foto',
      CaptureSource.audio => 'Transcrição',
    };
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

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          title,
          style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          text,
          style: AppText.label.copyWith(color: context.colors.inkSoft),
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
                  ? 'A foto não está mais neste celular. O texto continua salvo.'
                  : 'O áudio não está mais neste celular. A transcrição continua salva.',
              style: AppText.label.copyWith(color: c.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _Terms extends StatelessWidget {
  const _Terms({required this.terms, this.muted = false});

  final List<CaptureTerm> terms;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chips = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final term in terms) TermChip(label: term.text, muted: muted),
      ],
    );
    if (muted) return chips;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s2,
      children: [
        Text(
          terms.length == 1
              ? '1 termo escolhido'
              : '${terms.length} termos escolhidos',
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
