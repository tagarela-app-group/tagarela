import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/vocabulary/logic/group_controller.dart';

import '../../../helpers/fake_vocabulary_api.dart';

void main() {
  late FakeVocabulary vocabulary;
  late GroupController controller;

  setUp(() async {
    vocabulary = fakeVocabulary();
    await vocabulary.store.load();
    controller = GroupController(vocabulary.store);
  });

  tearDown(() => controller.dispose());

  test('tocar alterna o termo na seleção', () {
    controller.select({});

    controller.toggle('a');
    expect(controller.selected, {'a'});

    controller.toggle('b');
    controller.toggle('a');
    expect(controller.selected, {'b'});
  });

  test('selecionar tudo soma ao que já estava marcado', () {
    controller.select({'fora-do-filtro'});

    controller.selectAll(const [Term('a', 'a', TermKind.word, 0)]);

    expect(controller.selected, {'fora-do-filtro', 'a'});
  });

  test('selectedIn ignora termo marcado que não está na lista', () {
    controller.select({'a', 'sumiu'});

    final ids = controller.selectedIn(const [
      Term('a', 'a', TermKind.word, 0),
      Term('b', 'b', TermKind.word, 0),
    ]);

    expect(ids, ['a']);
  });

  test('filtro troca o status mostrado', () {
    expect(controller.status, isNull);

    controller.showFilter(2);

    expect(controller.filter, 2);
    expect(controller.status, TermStatus.mastered);
  });

  group('mudança', () {
    test('deu certo: limpa a seleção e libera', () async {
      controller.select({'u1'});

      final moving = controller.move(['u1'], '1');
      expect(controller.change, GroupChange.moving);

      expect(await moving, isTrue);
      expect(controller.change, isNull);
      expect(controller.selected, isNull);
    });

    test('falhou: mantém a seleção e libera', () async {
      controller.select({'u1'});
      vocabulary.api.offline = true;

      expect(await controller.delete(['u1']), isFalse);

      expect(controller.change, isNull);
      expect(controller.selected, {'u1'});
    });

    test('resposta depois de sair da tela não quebra', () async {
      final closing = GroupController(vocabulary.store);
      final moving = closing.move(['u1'], '1');

      closing.dispose();

      expect(await moving, isFalse);
    });
  });
}
