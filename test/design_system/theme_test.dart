import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

void main() {
  test('temas expõem AppColors como extensão', () {
    expect(AppTheme.light.extension<AppColors>(), AppColors.light);
    expect(AppTheme.dark.extension<AppColors>(), AppColors.dark);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  test('todo AppAccent tem cor nos dois temas', () {
    for (final colors in [AppColors.light, AppColors.dark]) {
      for (final accent in AppAccent.values) {
        expect(() => colors.accent(accent), returnsNormally, reason: '$accent');
      }
    }
  });

  test('lerp troca de tema na metade, sem interpolar', () {
    expect(AppColors.light.lerp(AppColors.dark, 0.4), AppColors.light);
    expect(AppColors.light.lerp(AppColors.dark, 0.5), AppColors.dark);
    expect(AppColors.light.lerp(null, 1), AppColors.light);
  });

  testWidgets('context.colors lê o tema atual', (tester) async {
    late AppColors colors;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) {
            colors = context.colors;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(colors, AppColors.dark);
  });
}
