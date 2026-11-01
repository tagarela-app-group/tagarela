import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/term/widgets/highlighted_text.dart';

void main() {
  test('acha o termo sem olhar maiúscula e em todas as vezes', () {
    expect(HighlightedText.find('Gap, the gap', 'gap'), [(0, 3), (9, 12)]);
  });

  test('não marca pedaço de outra palavra', () {
    expect(HighlightedText.find('a part of art', 'art'), [(10, 13)]);
    expect(HighlightedText.find('gaps', 'gap'), isEmpty);
    expect(HighlightedText.find('coração', 'cora'), isEmpty);
  });

  test('termo com caractere especial não quebra a busca', () {
    expect(HighlightedText.find('what? yes', 'what?'), [(0, 5)]);
  });
}
