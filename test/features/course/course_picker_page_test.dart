import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/course_picker_page.dart';
import 'package:tagarela/features/course/modals/base_language_modal.dart';

import '../../helpers/fake_course_api.dart';
import '../../helpers/pump_app.dart';

AppButton _start(WidgetTester tester) => tester.widget<AppButton>(
  find.descendant(of: find.byType(AppPage), matching: find.byType(AppButton)),
);

List<String> _flags(WidgetTester tester) => [
  for (final f in tester.widgetList<FlagBadge>(find.byType(FlagBadge)))
    f.country,
];

void main() {
  testWidgets(
    'primeiro acesso: fala o idioma do app e escolhe o que aprender',
    (tester) async {
      await tester.pumpPage(const CoursePickerPage(), load: false);
      await tester.pump();

      expect(find.text('Seus idiomas'), findsOneWidget);
      expect(find.text('Oi, tudo bem?'), findsOneWidget);
      expect(find.byType(TypingDots), findsOneWidget);
      expect(find.text('Português'), findsOneWidget);
      expect(find.text('O app inteiro fica nesse idioma'), findsOneWidget);
      expect(find.text('Trocar'), findsOneWidget);
      expect(find.text('Inglês'), findsOneWidget);
      expect(find.text('English · com áudio'), findsOneWidget);
      expect(find.text('Espanhol'), findsOneWidget);
      expect(find.text('Español · sem áudio por enquanto'), findsOneWidget);
      expect(_flags(tester), ['BR', 'BR', 'US', 'ES']);
      expect(find.byIcon(AppIcons.close), findsNothing);
      expect(_start(tester).label, 'Escolha o que quer aprender');
      expect(_start(tester).onPressed, isNull);
    },
  );

  testWidgets('celular em inglês: a tela inteira em inglês', (tester) async {
    await tester.pumpPage(
      const CoursePickerPage(),
      load: false,
      locale: const Locale('en'),
    );
    await tester.pump();

    expect(find.text('Your languages'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Portuguese'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(find.text('Inglês'), findsNothing);
  });

  testWidgets('escolher o que aprender responde no idioma e libera começar', (
    tester,
  ) async {
    await tester.pumpPage(const CoursePickerPage(), load: false);

    await tester.tap(find.text('Espanhol'));
    await tester.pumpAndSettle();

    expect(find.text('¡Hola! ¿Qué tal?'), findsOneWidget);
    expect(find.byType(TypingDots), findsNothing);
    expect(_start(tester).label, 'Começar a aprender espanhol');
    expect(_start(tester).onPressed, isNotNull);
  });

  testWidgets('trocar o que fala muda a tela e tira esse idioma da lista', (
    tester,
  ) async {
    await tester.pumpPage(const CoursePickerPage(), load: false);
    await tester.tap(find.text('Inglês'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trocar'));
    await tester.pumpAndSettle();

    expect(find.byType(BaseLanguageModal), findsOneWidget);
    expect(find.text('Eu falo'), findsWidgets);
    expect(
      find.text(
        'O app, as traduções e as explicações das fichas ficam nesse idioma',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('English').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(BaseLanguageModal), findsNothing);
    expect(find.text('Your languages'), findsOneWidget);
    expect(find.text("Hi, how's it going?"), findsOneWidget);
    expect(find.text('Portuguese'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(find.byType(TypingDots), findsOneWidget);
    expect(_start(tester).label, 'Pick what you want to learn');
  });

  testWidgets('quem já aprende outro idioma mantém a escolha ao trocar', (
    tester,
  ) async {
    await tester.pumpPage(const CoursePickerPage(), load: false);
    await tester.tap(find.text('Espanhol'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trocar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(_start(tester).label, 'Start learning Spanish');
  });

  testWidgets('pelo painel: X fecha e começar volta com o curso novo', (
    tester,
  ) async {
    final courses = fakeCourses();
    final scope = await tester.pumpPage(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => CoursePickerPage.open(Navigator.of(context)),
          child: const Text('abrir'),
        ),
      ),
      courses: courses.store,
    );
    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byIcon(AppIcons.close), findsOneWidget);
    await tester.tap(find.text('Espanhol'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar a aprender espanhol'));
    await tester.pumpAndSettle();

    expect(find.byType(CoursePickerPage), findsNothing);
    expect(scope.courses.active!.learning.name, 'es');
    expect(scope.courses.data, hasLength(2));
  });

  testWidgets('começa o curso com o idioma que a pessoa fala', (tester) async {
    final courses = fakeCourses(const []);
    await tester.pumpPage(
      const CoursePickerPage(),
      courses: courses.store,
      load: false,
    );
    await tester.tap(find.text('Espanhol'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trocar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start learning Spanish'));
    await tester.pump();

    expect(courses.api.bodies['POST /api/v1/courses'], {
      'learning': 'es',
      'base': 'en',
    });
  });

  testWidgets('sem rede: avisa no idioma da tela e continua na escolha', (
    tester,
  ) async {
    final courses = fakeCourses(const []);
    await tester.pumpPage(
      const CoursePickerPage(),
      courses: courses.store,
      load: false,
    );
    courses.api.offline = true;
    await tester.tap(find.text('Espanhol'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trocar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start learning Spanish'));
    await tester.pump();

    expect(
      find.text("Couldn't start now. Check your connection."),
      findsOneWidget,
    );
    expect(find.byType(CoursePickerPage), findsOneWidget);
    expect(_start(tester).loading, isFalse);
  });
}
