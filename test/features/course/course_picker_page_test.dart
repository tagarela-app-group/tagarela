import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/course_picker_page.dart';

import '../../helpers/fake_course_api.dart';
import '../../helpers/pump_app.dart';

AppButton _start(WidgetTester tester) => tester.widget<AppButton>(
  find.descendant(of: find.byType(SheetPage), matching: find.byType(AppButton)),
);

void main() {
  testWidgets('primeiro acesso: três idiomas e base do celular', (
    tester,
  ) async {
    await tester.pumpPage(const CoursePickerPage(), load: false);

    expect(find.text('O que você quer aprender?'), findsOneWidget);
    for (final name in ['Inglês', 'Espanhol']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('Português'), findsNWidgets(2));
    expect(find.text('English'), findsNWidgets(2));
    expect(find.text('Español · sem áudio por enquanto'), findsOneWidget);
    expect(find.byIcon(AppIcons.close), findsNothing);
    final base = tester.widget<SegmentedControl>(find.byType(SegmentedControl));
    expect(base.selected, 2);
    expect(_start(tester).label, 'Escolha o idioma que quer aprender');
    expect(_start(tester).onPressed, isNull);
  });

  testWidgets('base no idioma do celular em inglês', (tester) async {
    await tester.pumpPage(
      const CoursePickerPage(),
      load: false,
      locale: const Locale('en'),
    );

    final base = tester.widget<SegmentedControl>(find.byType(SegmentedControl));
    expect(base.selected, 0);
  });

  testWidgets('aprender o idioma da base bloqueia ele na base', (tester) async {
    await tester.pumpPage(const CoursePickerPage(), load: false);

    await tester.tap(find.text('Português').first);
    await tester.pumpAndSettle();

    final base = tester.widget<SegmentedControl>(find.byType(SegmentedControl));
    expect(base.selected, isNull);
    expect(base.disabled, {2});
    expect(_start(tester).label, 'Escolha por meio de qual idioma');

    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(_start(tester).label, 'Começar a aprender português');
    expect(_start(tester).onPressed, isNotNull);
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
    await tester.pumpAndSettle();

    expect(find.byIcon(AppIcons.close), findsOneWidget);
    await tester.tap(find.text('Espanhol'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar a aprender espanhol'));
    await tester.pumpAndSettle();

    expect(find.byType(CoursePickerPage), findsNothing);
    expect(scope.courses.active!.learning.name, 'es');
    expect(scope.courses.data, hasLength(2));
  });

  testWidgets('sem rede: avisa e continua na escolha', (tester) async {
    final courses = fakeCourses(const []);
    await tester.pumpPage(
      const CoursePickerPage(),
      courses: courses.store,
      load: false,
    );
    courses.api.offline = true;

    await tester.tap(find.text('Inglês'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar a aprender inglês'));
    await tester.pump();

    expect(
      find.text('Não deu pra começar agora. Confira sua conexão.'),
      findsOneWidget,
    );
    expect(find.byType(CoursePickerPage), findsOneWidget);
    expect(_start(tester).loading, isFalse);
  });
}
