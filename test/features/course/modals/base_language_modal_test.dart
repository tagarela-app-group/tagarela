import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/course/modals/base_language_modal.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<List<CourseLanguage?>> open(
    WidgetTester tester,
    CourseLanguage selected,
  ) async {
    final results = <CourseLanguage?>[];
    await tester.pumpPage(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                results.add(await BaseLanguageModal.show(context, selected)),
            child: const Text('abrir'),
          ),
        ),
      ),
      load: false,
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('idiomas do app pelo nome nativo, com o atual marcado', (
    tester,
  ) async {
    await open(tester, CourseLanguage.pt);

    expect(find.text('Eu falo'), findsOneWidget);
    expect(
      find.text('Mais idiomas aparecem aqui conforme o app for traduzido.'),
      findsOneWidget,
    );
    final rows = tester.widgetList<OptionRow>(find.byType(OptionRow)).toList();
    expect(
      [for (final r in rows) r.title],
      ['English', 'Español', 'Português'],
    );
    expect(
      [for (final r in rows) r.subtitle],
      ['Inglês', 'Espanhol', 'O app inteiro fica nesse idioma'],
    );
    expect([for (final r in rows) r.selected], [false, false, true]);
  });

  testWidgets('abre no idioma que a pessoa diz que fala', (tester) async {
    await open(tester, CourseLanguage.en);

    expect(find.text('I speak'), findsOneWidget);
    expect(find.text('Close'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.text('Portuguese'), findsOneWidget);
    expect(find.text('The whole app comes in this language'), findsOneWidget);
  });

  testWidgets('tocar devolve o idioma e fecha', (tester) async {
    final results = await open(tester, CourseLanguage.pt);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.byType(BaseLanguageModal), findsNothing);
    expect(results, [CourseLanguage.es]);
  });
}
