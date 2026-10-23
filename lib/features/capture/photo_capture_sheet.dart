import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/capture_device.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/capture/widgets/permission_notice.dart';
import 'package:tagarela/features/capture/widgets/privacy_note.dart';

class PhotoCaptureSheet extends StatefulWidget {
  const PhotoCaptureSheet({super.key});

  @override
  State<PhotoCaptureSheet> createState() => _PhotoCaptureSheetState();
}

class _PhotoCaptureSheetState extends State<PhotoCaptureSheet> {
  late final AppScope _scope;
  File? _photo;
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
    if (!mounted) {
      device.discard(photo);
      return;
    }
    setState(() => _photo = photo);
  }

  void _change() {
    _scope.device.discard(_photo!);
    setState(() => _photo = null);
  }

  Future<void> _save() async {
    final photo = _photo!;
    setState(() => _saving = true);
    final capture = await _scope.captures.createMedia(
      CaptureSource.photo,
      photo,
    );
    if (mounted) Navigator.pop(context, capture);
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;
    return AppSheet(
      icon: AppIcons.camera,
      accent: AppAccent.mango,
      title: 'Foto',
      subtitle: photo == null
          ? 'Uma placa, um cardápio, uma legenda'
          : 'Confira antes de salvar',
      child: _denied
          ? const PermissionNotice(
              icon: AppIcons.camera,
              accent: AppAccent.mango,
              title: 'Sem acesso à câmera',
              message:
                  'Libere a câmera nas configurações do celular pra tirar foto.',
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
                      icon: AppIcons.camera,
                      accent: AppAccent.mango,
                      title: 'Tirar foto',
                      subtitle: 'Abre a câmera do celular',
                      onTap: () => _pick(PhotoOrigin.camera),
                    ),
                    OptionRow(
                      icon: AppIcons.gallery,
                      accent: AppAccent.sky,
                      title: 'Escolher da galeria',
                      subtitle: 'Usa uma foto que você já tem',
                      onTap: () => _pick(PhotoOrigin.gallery),
                    ),
                  ],
                ),
                const PrivacyNote(
                  'A foto fica só no seu celular. A gente guarda apenas o texto lido dela.',
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s4,
              children: [
                Semantics(
                  label: 'Foto escolhida',
                  image: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Image.file(
                      photo,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 300,
                        color: context.colors.surfaceAlt,
                      ),
                    ),
                  ),
                ),
                Row(
                  spacing: AppSpacing.s2,
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Trocar foto',
                        variant: AppButtonVariant.outline,
                        onPressed: _saving ? null : _change,
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        label: 'Salvar no Inbox',
                        loading: _saving,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
