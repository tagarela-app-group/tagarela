import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_dependencies.dart';
import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/device/capture_device.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/capture/widgets/permission_notice.dart';
import 'package:tagarela/features/capture/widgets/privacy_note.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/capture_style.dart';
import 'package:tagarela/shared/widgets/audio_clip.dart';

enum _Phase { starting, recording, done, denied }

class AudioCaptureModal extends StatefulWidget {
  const AudioCaptureModal({super.key});

  @override
  State<AudioCaptureModal> createState() => _AudioCaptureModalState();
}

class _AudioCaptureModalState extends State<AudioCaptureModal> {
  static const _bars = [
    10,
    18,
    28,
    16,
    34,
    40,
    24,
    14,
    30,
    44,
    26,
    18,
    10,
    20,
    36,
    28,
    16,
    8,
    18,
    30,
    20,
    12,
    8,
    14,
    22,
    32,
    18,
    10,
  ];

  static const _tick = Duration(milliseconds: 200);

  late final AppDependencies _scope;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  _Phase _phase = _Phase.starting;
  File? _file;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _scope = AppScope.of(context);
    _start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    if (_phase == _Phase.recording) _scope.device.cancelRecording();
    final file = _file;
    if (file != null) {
      _scope.playback.stop();
      _scope.device.discard(file);
    }
    super.dispose();
  }

  Future<void> _start() async {
    final device = _scope.device;
    if (!await device.allowMicrophone()) {
      if (mounted) setState(() => _phase = _Phase.denied);
      return;
    }
    if (!mounted) return;
    await device.startRecording();
    if (!mounted) {
      await device.cancelRecording();
      return;
    }
    _ticker = Timer.periodic(_tick, (timer) {
      setState(() => _elapsed = _tick * timer.tick);
      if (_elapsed >= CaptureDevice.maxRecording) _stop();
    });
    setState(() {
      _elapsed = Duration.zero;
      _phase = _Phase.recording;
    });
  }

  Future<void> _stop() async {
    if (_phase != _Phase.recording) return;
    _ticker?.cancel();
    _phase = _Phase.starting;
    final file = await _scope.device.stopRecording();
    if (!mounted) {
      if (file != null) _scope.device.discard(file);
      return;
    }
    if (file == null) return Navigator.pop(context);
    setState(() {
      _file = file;
      _phase = _Phase.done;
    });
  }

  Future<void> _reRecord() async {
    final file = _file!;
    await _scope.playback.stop();
    _scope.device.discard(file);
    setState(() {
      _file = null;
      _phase = _Phase.starting;
    });
    await _start();
  }

  Future<void> _save() async {
    final file = _file!;
    setState(() => _saving = true);
    await _scope.playback.stop();
    final capture = await _scope.captures.createMedia(
      CaptureSource.audio,
      file,
    );
    if (mounted) Navigator.pop(context, capture);
  }

  @override
  Widget build(BuildContext context) {
    final recording = _phase == _Phase.recording || _phase == _Phase.starting;
    return AppModal(
      icon: CaptureSource.audio.glyph,
      accent: CaptureSource.audio.accent,
      title: recording ? context.l10n.recording : context.l10n.recordAudio,
      subtitle: _phase == _Phase.done
          ? context.l10n.listenBeforeSaving
          : context.l10n.recordHint,
      child: switch (_phase) {
        _Phase.denied => PermissionNotice(
          icon: CaptureSource.audio.glyph,
          accent: CaptureSource.audio.accent,
          title: context.l10n.micDeniedTitle,
          message: context.l10n.micDeniedMessage,
        ),
        _Phase.done => _done(_file!),
        _ => _recording(context),
      },
    );
  }

  Widget _recording(BuildContext context) {
    final c = context.colors;
    final accent = c.accent(CaptureSource.audio.accent);
    final max = CaptureDevice.maxRecording;
    final elapsed = _elapsed > max ? max : _elapsed;
    return Column(
      spacing: AppSpacing.s4,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: AppSpacing.s2,
          children: [
            Text(
              clockLabel(elapsed),
              style: AppText.display.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              context.l10n.ofDuration(clockLabel(max)),
              style: AppText.bodyMd.copyWith(color: c.inkSoft),
            ),
          ],
        ),
        ExcludeSemantics(
          child: SizedBox(
            height: 48,
            child: ClipRect(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.s1,
                children: [
                  for (final h in _bars)
                    Container(
                      width: 4,
                      height: h.toDouble(),
                      decoration: BoxDecoration(
                        color: accent.fg,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SegmentBar(
          segments: [Segment(elapsed.inMilliseconds, accent.fg)],
          total: max.inMilliseconds,
          height: 6,
          semanticLabel: context.l10n.recordingTime,
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: accent.soft, spreadRadius: 8)],
            ),
            child: IconButton(
              onPressed: _phase == _Phase.recording ? _stop : null,
              tooltip: context.l10n.stopRecording,
              icon: const Icon(AppIcons.stop),
              iconSize: 26,
              style: IconButton.styleFrom(
                backgroundColor: AppPalette.coral,
                foregroundColor: AppPalette.ink,
                disabledBackgroundColor: AppPalette.coral,
                disabledForegroundColor: AppPalette.ink,
                fixedSize: const Size.square(76),
                shape: const CircleBorder(),
              ),
            ),
          ),
        ),
        Text(
          context.l10n.tapToStop,
          style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _done(File file) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: AppSpacing.s4,
    children: [
      AudioClip(file: file),
      PrivacyNote(context.l10n.audioPrivacy),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s3,
        children: [
          AppButton(
            label: context.l10n.saveToInbox,
            loading: _saving,
            onPressed: _save,
          ),
          AppButton(
            label: context.l10n.reRecord,
            variant: AppButtonVariant.outline,
            onPressed: _saving ? null : _reRecord,
          ),
        ],
      ),
    ],
  );
}
