import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/course_picker_page.dart';
import 'package:tagarela/features/course/modals/course_modal.dart';

import '../../../helpers/fake_course_api.dart';
import '../../../helpers/fake_vocabulary_api.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeCourses courses;
  late FakeVocabulary vocabulary;

  Future<void> openModal(WidgetTester tester) async {
    await tester.pumpPage(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => CourseModal.show(context),
            child: const Text('abrir'),
          ),
        ),
      ),
      deps: fakeDependencies(
        courses: courses.store,
        vocabulary: vocabulary.store,
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    courses = fakeCourses([englishCourseJson, spanishCourseJson]);
    vocabulary = fakeVocabulary();
  });

  testWidgets('lista os cursos com as bandeiras, termos e idioma do app', (
    tester,
  ) async {
    await openModal(tester);

    expect(find.text('Seus cursos'), findsOneWidget);
    expect(
      find.text('O app fica no idioma que você fala no curso ativo.'),
      findsOneWidget,
    );
    expect(find.text('Português → Inglês'), findsOneWidget);
    expect(find.text('8 termos'), findsOneWidget);
    expect(find.text('Inglês → Espanhol'), findsOneWidget);
    expect(find.text('2 termos · app em English'), findsOneWidget);
    final pairs = tester.widgetList<FlagPair>(find.byType(FlagPair));
    expect(
      [for (final p in pairs) (p.back, p.front)],
      [('BR', 'US'), ('US', 'ES')],
    );
    final rows = tester.widgetList<OptionRow>(find.byType(OptionRow));
    expect(rows.map((r) => r.selected), [true, false]);
  });

  testWidgets('trocar de curso ativa e recarrega o vocabulário', (
    tester,
  ) async {
    await openModal(tester);
    vocabulary.api.calls.clear();

    await tester.tap(find.text('Inglês → Espanhol'));
    await tester.pumpAndSettle();

    expect(find.byType(CourseModal), findsNothing);
    expect(courses.store.active!.id, 'curso-es');
    expect(vocabulary.api.calls, ['GET /api/v1/vocabulary']);
  });

  testWidgets('curso ativo só fecha', (tester) async {
    await openModal(tester);
    courses.api.calls.clear();

    await tester.tap(find.text('Português → Inglês'));
    await tester.pumpAndSettle();

    expect(find.byType(CourseModal), findsNothing);
    expect(courses.api.calls, isEmpty);
  });

  testWidgets('sem rede: avisa e fica no painel', (tester) async {
    await openModal(tester);
    courses.api.offline = true;

    await tester.tap(find.text('Inglês → Espanhol'));
    await tester.pump();

    expect(
      find.text('Não deu pra trocar de curso. Confira sua conexão.'),
      findsOneWidget,
    );
    expect(find.byType(CourseModal), findsOneWidget);
    expect(courses.store.active!.id, 'curso-en');
  });

  testWidgets('aprender outro idioma abre a escolha', (tester) async {
    await openModal(tester);

    await tester.tap(find.text('Aprender outro idioma'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CourseModal), findsNothing);
    expect(find.byType(CoursePickerPage), findsOneWidget);
  });
}
