import 'package:flutter/widgets.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';

extension CaptureSourceStyle on CaptureSource {
  IconData get glyph => switch (this) {
    CaptureSource.photo => AppIcons.camera,
    CaptureSource.audio => AppIcons.audio,
    CaptureSource.text => AppIcons.text,
  };

  AppAccent get accent => switch (this) {
    CaptureSource.photo => AppAccent.mango,
    CaptureSource.audio => AppAccent.coral,
    CaptureSource.text => AppAccent.violet,
  };
}
