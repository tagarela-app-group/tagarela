import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/practice/logic/keyboard_rows.dart';

void main() {
  test('inglês: só as três fileiras', () {
    expect(keyboardRows(CourseLanguage.en, 'awkward'), [
      'qwertyuiop',
      'asdfghjkl',
      'zxcvbnm',
    ]);
  });

  test('espanhol e português ganham ñ ou ç e uma fileira de acentos', () {
    expect(keyboardRows(CourseLanguage.es, 'año'), [
      'áéíóúü',
      'qwertyuiop',
      'asdfghjklñ',
      'zxcvbnm',
    ]);
    expect(keyboardRows(CourseLanguage.pt, 'ação').first, 'áâãàéêíóôõú');
    expect(keyboardRows(CourseLanguage.pt, 'ação')[2], 'asdfghjklç');
  });

  test('letra da resposta que falta no teclado entra em cima', () {
    expect(keyboardRows(CourseLanguage.en, "Café's").first, 'é');
  });
}
