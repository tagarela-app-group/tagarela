import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/features/inbox/term_selection.dart';

import '../../helpers/fake_capture_store.dart';

void main() {
  const text = 'Please mind the gap between the train and the platform.';

  List<String> terms(TermSelection selection) => [
    for (final span in selection.spans) selection.termText(span),
  ];

  TermSelection pick(TermSelection selection, int first, [int? last]) =>
      selection.toggle(selection.spanOf(first, last ?? first));

  test('palavras: pontuação da ponta fica fora do termo', () {
    final words = TermSelection.wordsOf('"Hi," she said — ok.');

    expect(words.map((w) => w.label), ['"Hi,"', 'she', 'said', '—', 'ok.']);
    expect((words.first.start, words.first.end), (1, 3));
    expect(words[3].selectable, isFalse);
    expect(
      '"Hi," she said — ok.'.substring(words[4].start, words[4].end),
      'ok',
    );
  });

  test('palavra com acento combinado continua inteira', () {
    final word = TermSelection.wordsOf('café!').single;

    expect((word.start, word.end), (0, 5));
  });

  test('toque marca e desmarca a palavra', () {
    final marked = pick(TermSelection(text, const []), 3);

    expect(terms(marked), ['gap']);
    expect(terms(pick(marked, 3)), isEmpty);
  });

  test('expressão e palavra dentro dela convivem, na ordem do texto', () {
    var selection = TermSelection(text, const []);
    selection = pick(selection, 9);
    selection = pick(selection, 1);
    selection = pick(selection, 1, 3);

    expect(terms(selection), ['mind the gap', 'mind', 'platform']);
  });

  test('remove tira só o termo escolhido', () {
    final selection = pick(pick(TermSelection(text, const []), 1, 3), 1);

    expect(terms(selection.remove(selection.spanOf(1, 3))), ['mind']);
  });

  test('posição vai e volta da API em code points', () {
    const emoji = 'I love 🍕 pizza';
    final selection = pick(TermSelection(emoji, const []), 3);

    expect(selection.toTerms(), const [
      CaptureTerm(text: 'pizza', start: 9, end: 14),
    ]);
    final loaded = TermSelection.of(
      sampleCapture('c', text: emoji, terms: selection.toTerms()),
    );
    expect(terms(loaded), ['pizza']);
  });

  group('editar texto', () {
    final selection = pick(pick(TermSelection(text, const []), 1), 3);

    test('termo antes da mudança fica, o de depois acompanha', () {
      final edited = selection.edit(
        'Please mind the big gap between the train and the platform.',
      );

      expect(terms(edited), ['mind', 'gap']);
      expect(edited.spans.last, (start: 20, end: 23));
    });

    test('palavra que mudou perde o termo', () {
      final edited = selection.edit(
        'Please mind the gaps between the train and the platform.',
      );

      expect(terms(edited), ['mind']);
    });

    test('expressão que encosta na mudança cai', () {
      final edited = pick(
        TermSelection(text, const []),
        1,
        3,
      ).edit('Please mind a gap between the train and the platform.');

      expect(edited.spans, isEmpty);
    });

    test('mesmo texto não muda nada', () {
      expect(selection.edit(text), same(selection));
    });
  });

  group('limites da API', () {
    final long = List.filled(60, 'word').join(' ');

    test('expressão grande demais', () {
      final selection = TermSelection(long, const []);

      expect(selection.limit(selection.spanOf(0, 59)), TermLimit.tooLong);
      expect(selection.limit(selection.spanOf(0, 1)), isNull);
    });

    test('termos demais, mas tirar continua liberado', () {
      var selection = TermSelection(long, const []);
      for (var i = 0; i < TermSelection.maxTerms; i++) {
        selection = pick(selection, i);
      }

      expect(selection.limit(selection.spanOf(50, 50)), TermLimit.tooMany);
      expect(selection.limit(selection.spanOf(0, 0)), isNull);
    });
  });
}
