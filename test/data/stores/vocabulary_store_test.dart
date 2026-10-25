import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/fake_vocabulary_api.dart';
import '../../helpers/fixtures.dart';

void main() {
  test('carrega o vocabulário da API', () async {
    final (:store, :api) = fakeVocabulary();

    await store.load();

    expect(api.calls, ['GET /api/v1/vocabulary']);
    expect(store.data!.groups, hasLength(sampleVocabulary.groups.length));
    expect(store.data!.ungrouped.map((t) => t.text), [
      'mind the gap',
      'stand clear',
    ]);
  });

  test('criar grupo põe ele no topo e devolve', () async {
    final (:store, :api) = fakeVocabulary();
    await store.load();

    final group = await store.createGroup(
      name: 'Música',
      icon: GroupIcon.music,
      accent: AppAccent.pink,
    );

    expect(api.bodies['POST /api/v1/groups'], {
      'name': 'Música',
      'icon': 'music',
      'accent': 'pink',
    });
    expect(group.icon, AppIcons.music);
    expect(store.data!.groups.first.id, group.id);
  });

  test('nome repetido: erro da API com a mensagem do campo', () async {
    final (:store, api: _) = fakeVocabulary();
    await store.load();

    await expectLater(
      store.createGroup(
        name: 'viagem',
        icon: GroupIcon.travel,
        accent: AppAccent.sky,
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.fieldError('name'),
          'name',
          'Você já tem um grupo com esse nome.',
        ),
      ),
    );
    expect(store.data!.groups, hasLength(sampleVocabulary.groups.length));
  });

  test('mover troca o vocabulário pelo da resposta', () async {
    final (:store, :api) = fakeVocabulary();
    await store.load();

    await store.move(['u1'], '1');

    expect(api.bodies['POST /api/v1/terms/move'], {
      'terms': ['u1'],
      'group': '1',
    });
    expect(store.data!.ungrouped.map((t) => t.id), ['u2']);
    expect(store.data!.group('1')!.terms.first.text, 'mind the gap');
  });

  test('mover pra Sem grupo manda grupo nulo', () async {
    final (:store, :api) = fakeVocabulary();
    await store.load();

    await store.move(['t1'], null);

    expect(api.bodies['POST /api/v1/terms/move'], {
      'terms': ['t1'],
      'group': null,
    });
    expect(store.data!.ungrouped.first.id, 't1');
  });

  test('sem rede: mover falha e nada muda', () async {
    final (:store, :api) = fakeVocabulary();
    await store.load();
    final before = store.data;
    api.offline = true;

    await expectLater(store.move(['u1'], '1'), throwsException);

    expect(store.data, same(before));
  });

  test('ficha do termo vem da API com prazo longo', () async {
    final (:store, :api) = fakeVocabulary();

    final detail = await store.term('u1');

    expect(api.calls, ['GET /api/v1/terms/u1']);
    expect(detail.term.text, 'mind the gap');
    expect(detail.card.base.headline, 'cuidado com o vão');
    expect(
      VocabularyService.cardTimeout,
      greaterThan(const Duration(seconds: 30)),
    );
  });

  test('revelar manda o estado e devolve a ficha', () async {
    final (:store, :api) = fakeVocabulary();

    final detail = await store.reveal('u1', revealed: true);

    expect(api.bodies['PATCH /api/v1/terms/u1'], {'revealed': true});
    expect(detail.revealed, isTrue);
  });
}
