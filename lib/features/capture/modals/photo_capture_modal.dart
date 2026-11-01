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

class PhotoCaptureModal extends StatefulWidget {
  const PhotoCaptureModal({super.key});

  @override
  State<PhotoCaptureModal> createState() => _PhotoCaptureModalState();
}

class _PhotoCaptureModalState extends State<PhotoCaptureModal> {
  late final AppDependencies _scope;
  static const _frameHeight = 400.0;

  File? _photo;
  Size? _size;
  Rect _area = CropFrame.full;
  bool _denied = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _scope = AppScope.of(context);
  }

  @override
  void dispose() {
    final photo = _photo;
    if (photo != null) _scope.device.discard(photo);
    super.dispose();
  }

  Future<void> _pick(PhotoOrigin origin) async {
    final device = _scope.device;
    if (origin == PhotoOrigin.camera && !await device.allowCamera()) {
      if (mounted) setState(() => _denied = true);
      return;
    }
    final photo = await device.photo(origin);
    if (photo == null) return;
    final size = await device.imageSize(photo);
    if (!mounted) {
      device.discard(photo);
      return;
    }
    setState(() {
      _photo = photo;
      _size = size;
      _area = CropFrame.full;
    });
  }

  void _change() {
    _scope.device.discard(_photo!);
    setState(() => _photo = null);
  }

  Future<void> _save() async {
    final photo = _photo!;
    setState(() => _saving = true);
    final cropped = await _cropped(photo);
    final capture = await _scope.captures.createMedia(
      CaptureSource.photo,
      cropped ?? photo,
    );
    if (cropped != null) _scope.device.discard(cropped);
    if (mounted) Navigator.pop(context, capture);
  }

  Future<File?> _cropped(File photo) async {
    if (_area == CropFrame.full) return null;
    try {
      return await _scope.device.crop(photo, _area);
    } on Exception {
      return null;
    }
  }

  Widget _image(File photo, {double? height, BoxFit fit = BoxFit.cover}) =>
      Image.file(
        photo,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) =>
            Container(height: height, color: context.colors.surfaceAlt),
      );

  @override
  Widget build(BuildContext context) {
    final photo = _photo;
    final size = _size;
    return AppModal(
      icon: CaptureSource.photo.glyph,
      accent: CaptureSource.photo.accent,
      title: context.l10n.photo,
      subtitle: photo == null
          ? context.l10n.photoHint
          : size == null
          ? context.l10n.checkBeforeSaving
          : context.l10n.cropHint,
      child: _denied
          ? PermissionNotice(
              icon: CaptureSource.photo.glyph,
              accent: CaptureSource.photo.accent,
              title: context.l10n.cameraDeniedTitle,
              message: context.l10n.cameraDeniedMessage,
            )
          : photo == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s4,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.s3,
                  children: [
                    OptionRow(
                      icon: CaptureSource.photo.glyph,
                      accent: CaptureSource.photo.accent,
                      title: context.l10n.takePhoto,
                      subtitle: context.l10n.takePhotoHint,
                      onTap: () => _pick(PhotoOrigin.camera),
                    ),
                    OptionRow(
                      icon: AppIcons.gallery,
                      accent: AppAccent.sky,
                      title: context.l10n.pickFromGallery,
                      subtitle: context.l10n.pickFromGalleryHint,
                      onTap: () => _pick(PhotoOrigin.gallery),
                    ),
                  ],
                ),
                PrivacyNote(context.l10n.photoPrivacy),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s4,
              children: [
                Semantics(
                  label: context.l10n.chosenPhoto,
                  image: true,
                  child: size == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: _image(photo, height: 300),
                        )
                      : CropFrame(
                          imageSize: size,
                          maxHeight: _frameHeight,
                          area: _area,
                          onChanged: _saving
                              ? (_) {}
                              : (area) => setState(() => _area = area),
                          child: _image(photo, fit: BoxFit.fill),
                        ),
                ),
                if (size != null)
                  AnimatedOpacity(
                    opacity: _area == CropFrame.full ? 0 : 1,
                    duration: AppMotion.base,
                    child: IgnorePointer(
                      ignoring: _area == CropFrame.full || _saving,
                      child: ExcludeSemantics(
                        excluding: _area == CropFrame.full,
                        child: Center(
                          child: AppButton(
                            label: context.l10n.cropUndo,
                            leading: const Icon(
                              AppIcons.undo,
                              size: AppIconSize.sm,
                            ),
                            variant: AppButtonVariant.text,
                            size: AppButtonSize.small,
                            onPressed: () =>
                                setState(() => _area = CropFrame.full),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                      label: context.l10n.changePhoto,
                      variant: AppButtonVariant.outline,
                      onPressed: _saving ? null : _change,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
