import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/shared/logic/exercise_style.dart';

void main() {
  test('cada minigame tem ícone próprio', () {
    const kinds = ExerciseKind.values;

    expect(kinds.map((k) => k.glyph).toSet(), hasLength(kinds.length));
    expect(ExerciseKind.listenWrite.glyph, AppIcons.headphones);
  });
}
