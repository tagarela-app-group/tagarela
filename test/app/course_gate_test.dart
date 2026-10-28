import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/course_gate.dart';
import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/features/course/course_picker_page.dart';

import '../helpers/fake_course_api.dart';
import '../helpers/fake_vocabulary_api.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('conta com curso vai direto pro app', (tester) async {
    await tester.pumpPage(const CourseGate());
    await tester.pumpAndSettle();

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(CoursePickerPage), findsNothing);
  });

  testWidgets('conta sem curso escolhe o par e entra no app', (tester) async {
    final courses = fakeCourses(const []);
    final vocabulary = fakeVocabulary();
    final scope = await tester.pumpPage(
      const CourseGate(),
      deps: fakeDependencies(
        courses: courses.store,
        vocabulary: vocabulary.store,
      ),
    );
    await tester.pump();

    expect(find.byType(CoursePickerPage), findsOneWidget);
    expect(vocabulary.api.calls, isEmpty);

    await tester.tap(find.text('Espanhol'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar a aprender espanhol'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeShell), findsOneWidget);
    expect(scope.courses.active!.id, 'curso-es-pt');
    expect(vocabulary.api.calls, ['GET /api/v1/vocabulary']);
  });
}
