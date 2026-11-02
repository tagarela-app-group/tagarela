import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/shared/widgets/practice_cards.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('mostra só os jogos que o curso já pode jogar', (tester) async {
    final opened = <ExerciseKind>[];
    await tester.pumpComponent(
      PracticeCards(kinds: const [ExerciseKind.reply], onOpen: opened.add),
    );

    expect(find.text('Ouvir e escrever'), findsNothing);

    await tester.tap(find.text('Responde aí'));

    expect(opened, [ExerciseKind.reply]);
  });
}
