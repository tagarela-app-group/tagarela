import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

bool _obscured(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).obscureText;

void main() {
  testWidgets('mostra rótulo, dica e ícone', (tester) async {
    await tester.pumpComponent(
      const AppTextField(
        label: 'E-mail',
        hint: 'voce@email.com',
        icon: AppIcons.mail,
      ),
    );

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('voce@email.com'), findsOneWidget);
    expect(find.byIcon(AppIcons.mail), findsOneWidget);
  });

  testWidgets('repassa texto digitado em onChanged', (tester) async {
    String? typed;
    await tester.pumpComponent(AppTextField(onChanged: (v) => typed = v));

    await tester.enterText(find.byType(TextField), 'hello');
    expect(typed, 'hello');
  });

  testWidgets('mostra errorText', (tester) async {
    await tester.pumpComponent(
      const AppTextField(errorText: 'E-mail inválido'),
    );

    expect(find.text('E-mail inválido'), findsOneWidget);
  });

  testWidgets('mostra helperText e troca pelo erro quando houver', (
    tester,
  ) async {
    await tester.pumpComponent(
      const AppTextField(helperText: 'Mínimo de 8 caracteres.'),
    );
    expect(find.text('Mínimo de 8 caracteres.'), findsOneWidget);

    await tester.pumpComponent(
      const AppTextField(
        helperText: 'Mínimo de 8 caracteres.',
        errorText: 'Senha curta.',
      ),
    );
    expect(find.text('Mínimo de 8 caracteres.'), findsNothing);
    expect(find.text('Senha curta.'), findsOneWidget);
  });

  testWidgets('campo comum não tem botão de senha', (tester) async {
    await tester.pumpComponent(const AppTextField());

    expect(_obscured(tester), isFalse);
    expect(find.byType(AppIconButton), findsNothing);
  });

  testWidgets('obscure alterna mostrar/ocultar senha', (tester) async {
    await tester.pumpComponent(const AppTextField(obscure: true));

    expect(_obscured(tester), isTrue);
    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();

    expect(_obscured(tester), isFalse);
    await tester.tap(find.byTooltip('Ocultar senha'));
    await tester.pump();

    expect(_obscured(tester), isTrue);
  });
}
