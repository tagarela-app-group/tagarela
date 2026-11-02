import 'package:flutter/widgets.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';

extension ExerciseKindStyle on ExerciseKind {
  IconData get glyph => switch (this) {
    ExerciseKind.listenWrite => AppIcons.headphones,
    ExerciseKind.reply => AppIcons.talk,
  };
}
