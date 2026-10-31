import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class CaptureThumbnail extends StatelessWidget {
  const CaptureThumbnail({super.key, required this.file});

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
