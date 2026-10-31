import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

void main() {
  test('todo AppAccent tem cor nos dois temas', () {
    for (final colors in [AppColors.light, AppColors.dark]) {
      for (final accent in AppAccent.values) {
        expect(() => colors.accent(accent), returnsNormally, reason: '$accent');
      }
    }
  });
}
