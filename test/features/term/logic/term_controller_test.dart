import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/term/logic/term_controller.dart';

import '../../../helpers/fake_vocabulary_api.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeVocabulary vocabulary;
  late TermController term;

  setUp(() {
    vocabulary = fakeVocabulary();
    term = TermController(vocabulary.store, 'u1');
  });

  tearDown(() => term.dispose());

  group('reveal', () {
    setUp(() => term.load());

    test('salva só o que foi revelado', () async {
      for (final (note, field) in [
        (TermNote.remember, 'revealed'),
        (TermNote.pitfall, 'pitfall_revealed'),
        (TermNote.formality, 'formality_revealed'),
      ]) {
        term.reveal(note, revealed: true);
        await pumpEventQueue();

        expect(term.revealed(note), isTrue, reason: field);
        expect(vocabulary.api.bodies['PATCH /api/v1/terms/u1'], {field: true});
      }
    });

    test('revelar de novo não salva nem solta balões', () async {
      term.reveal(TermNote.remember, revealed: true);
      await pumpEventQueue();
      final calls = vocabulary.api.calls.length;

      term.reveal(TermNote.remember, revealed: true);
      await pumpEventQueue();

      expect(vocabulary.api.calls, hasLength(calls));
      expect(term.bursts(TermNote.remember), 1);
    });

    test('embaçar não solta balões e tira a pergunta', () {
      term.reveal(TermNote.remember, revealed: true);
      expect(term.asked, isTrue);

      term.reveal(TermNote.remember, revealed: false);

      expect(term.revealed(TermNote.remember), isFalse);
      expect(term.bursts(TermNote.remember), 1);
      expect(term.asked, isFalse);
    });

    test('pegadinha não entrega o pra lembrar nem pergunta', () {
      term.reveal(TermNote.pitfall, revealed: true);

      expect(term.revealed(TermNote.remember), isFalse);
      expect(term.bursts(TermNote.remember), 0);
      expect(term.asked, isFalse);
    });

    test('falha ao salvar mantém revelado', () async {
      vocabulary.api.offline = true;

      term.reveal(TermNote.remember, revealed: true);
      await pumpEventQueue();

      expect(term.revealed(TermNote.remember), isTrue);
    });
  });

  group('load', () {
    test('ficha já revelada abre revelada, sem balões nem pergunta', () async {
      vocabulary.api
        ..revealed.add('u1')
        ..pitfallRevealed.add('u1');

      await term.load();

      expect(term.revealed(TermNote.remember), isTrue);
      expect(term.revealed(TermNote.pitfall), isTrue);
      expect(term.revealed(TermNote.formality), isFalse);
      expect(term.bursts(TermNote.remember), 0);
      expect(term.asked, isFalse);
    });

    test('falha guarda o erro e nova tentativa limpa', () async {
      vocabulary.api.offline = true;
      await term.load();
      expect(term.error, isNotNull);
      expect(term.detail, isNull);

      vocabulary.api.offline = false;
      await term.load();

      expect(term.error, isNull);
      expect(term.detail, isNotNull);
    });

    test('resposta depois de sair da tela não quebra', () async {
      final closing = TermController(vocabulary.store, 'u1');
      final loading = closing.load();

      closing.dispose();

      await expectLater(loading, completes);
    });
  });

  group('tabs', () {
    test('sem ficha: nenhuma aba', () {
      expect(term.tabs, isEmpty);
      expect(term.tab, isNull);
    });

    test('só aparece aba com conteúdo', () async {
      vocabulary.api.cards['u1'] = {
        ...sampleCardJson,
        'dialogue': <Object?>[],
        'examples': <Object?>[],
        'collocations': <Object?>[],
        'synonyms': <Object?>[],
        'antonyms': <Object?>[],
      };

      await term.load();

      expect(term.tabs, isNot(contains(TermTab.words)));
      expect(term.tabs, contains(TermTab.usage));
    });

    test('aba escolhida que some cai na primeira', () async {
      await term.load();
      term.select(TermTab.usage);
      expect(term.tab, TermTab.usage);

      vocabulary.api.cards['u1'] = {
        ...sampleCardJson,
        'formality': null,
        'base': {...sampleCardJson['base']! as Json, 'fits': <Object?>[]},
      };
      await term.load();

      expect(term.tab, term.tabs.first);
    });
  });

  test('virar alterna o lado do card', () {
    expect(term.flipped, isFalse);

    term.flip();
    expect(term.flipped, isTrue);

    term.flip();
    expect(term.flipped, isFalse);
  });
}
