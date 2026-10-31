import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';

void main() {
  const text = '😀 mind the gap';

  test('emoji conta 1 pra API e 2 pro Dart', () {
    expect(codeUnitOffset(text, 2), 3);
    expect(codePointOffset(text, 3), 2);
  });

  test('ida e volta devolve o mesmo trecho', () {
    final start = codeUnitOffset(text, 2);
    final end = codeUnitOffset(text, 6);

    expect(text.substring(start, end), 'mind');
    expect(codePointOffset(text, start), 2);
    expect(codePointOffset(text, end), 6);
  });

  test('posição além do fim para no fim do texto', () {
    expect(codeUnitOffset('abc', 10), 3);
  });
}
