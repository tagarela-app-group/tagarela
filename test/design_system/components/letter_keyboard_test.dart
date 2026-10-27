import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('cada tecla manda a letra; apagar e ação têm o próprio toque', (
    tester,
  ) async {
    final typed = <String>[];
    var erased = 0;
    var hints = 0;
    await tester.pumpComponent(
      LetterKeyboard(
        rows: const ['áé', 'qwertyuiop', 'asdfghjkl', 'zxcvbnm'],
        onLetter: typed.add,
        onBackspace: () => erased++,
        backspaceLabel: 'Apagar',
        letterLabel: (letter) => 'Letra $letter',
        action: KeyboardAction(
          icon: AppIcons.idea,
          label: 'Dica',
          tone: StatusTone.learning,
          onPressed: () => hints++,
        ),
      ),
    );

    await tester.tap(find.text('q'));
    await tester.tap(find.bySemanticsLabel('Letra é'));
    await tester.tap(find.bySemanticsLabel('Apagar'));
    await tester.tap(find.bySemanticsLabel('Dica'));

    expect(typed, ['q', 'é']);
    expect(erased, 1);
    expect(hints, 1);
  });

  testWidgets('a fileira mais longa define a largura de todas as teclas', (
    tester,
  ) async {
    await tester.pumpComponent(
      LetterKeyboard(
        rows: const ['áâãàéêíóôõú', 'qwertyuiop'],
        onLetter: (_) {},
        onBackspace: () {},
        backspaceLabel: 'Apagar',
        letterLabel: (letter) => letter,
      ),
    );

    final q = tester.getSize(find.bySemanticsLabel('q'));
    final a = tester.getSize(find.bySemanticsLabel('á'));
    expect(q.width, a.width);
    expect(q.height, LetterKeyboard.keyHeight);
    expect(tester.takeException(), isNull);
  });
}
