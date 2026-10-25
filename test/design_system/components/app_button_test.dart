import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra rótulo e chama onPressed no toque', (tester) async {
    var taps = 0;
    await tester.pumpComponent(
      AppButton(label: 'Entrar', onPressed: () => taps++),
    );

    await tester.tap(find.text('Entrar'));
    expect(taps, 1);
  });

  testWidgets('onPressed nulo desabilita o botão', (tester) async {
    await tester.pumpComponent(
      const AppButton(label: 'Entrar', onPressed: null),
    );

    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.enabled, isFalse);
  });

  testWidgets('mostra leading antes do rótulo', (tester) async {
    await tester.pumpComponent(
      AppButton(
        label: 'Google',
        onPressed: () {},
        leading: const Icon(AppIcons.add),
      ),
    );

    expect(find.byIcon(AppIcons.add), findsOneWidget);
  });

  testWidgets('loading troca o leading por spinner e ignora toque', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpComponent(
      AppButton(
        label: 'Google',
        onPressed: () => taps++,
        leading: const Icon(AppIcons.add),
        loading: true,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(AppIcons.add), findsNothing);
    expect(find.text('Google'), findsOneWidget);

    await tester.tap(find.text('Google'), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('loading sem onPressed mantém a cor da variante', (tester) async {
    await tester.pumpComponent(
      const AppButton(label: 'Entrar', onPressed: null, loading: true),
    );

    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.enabled, isTrue);
  });

  testWidgets('todas as variantes e tamanhos montam', (tester) async {
    for (final variant in AppButtonVariant.values) {
      for (final size in AppButtonSize.values) {
        await tester.pumpComponent(
          AppButton(
            label: 'Ok',
            onPressed: () {},
            variant: variant,
            size: size,
          ),
        );
        expect(tester.takeException(), isNull, reason: '$variant $size');
      }
    }
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('contrast usa contrast/onContrast (${theme.brightness.name})', (
      tester,
    ) async {
      await tester.pumpComponent(
        AppButton(
          label: 'Apple',
          onPressed: () {},
          variant: AppButtonVariant.contrast,
        ),
        theme: theme,
      );

      final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
      expect(style.backgroundColor!.resolve({}), colors.contrast);
      expect(style.foregroundColor!.resolve({}), colors.onContrast);
    });

    testWidgets('danger usa alert/onAlert (${theme.brightness.name})', (
      tester,
    ) async {
      await tester.pumpComponent(
        AppButton(
          label: 'Apagar grupo',
          onPressed: () {},
          variant: AppButtonVariant.danger,
        ),
        theme: theme,
      );

      final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
      expect(style.backgroundColor!.resolve({}), colors.alert);
      expect(style.foregroundColor!.resolve({}), colors.onAlert);
    });
  }

  testWidgets('expand ocupa a largura toda', (tester) async {
    await tester.pumpComponent(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [AppButton(label: 'Ok', onPressed: () {}, expand: true)],
      ),
    );

    expect(tester.getSize(find.byType(TextButton)).width, 800);
  });

  testWidgets('onHeader: pílula no tom do header, texto branco', (
    tester,
  ) async {
    await tester.pumpComponent(
      AppButton(
        label: 'Mover termos',
        onPressed: () {},
        variant: AppButtonVariant.onHeader,
        size: AppButtonSize.small,
      ),
    );

    final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
    final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
    expect(style.backgroundColor!.resolve({}), AppColors.light.headerChip);
    expect(style.foregroundColor!.resolve({}), AppPalette.white);
    expect(shape.borderRadius, BorderRadius.circular(AppRadius.pill));
  });
}
