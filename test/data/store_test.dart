import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/store.dart';

/// Store de teste: devolve o próximo valor ou lança o próximo erro.
class _NumberStore extends Store<int> {
  Object? next;

  @override
  Future<int> fetch() async => switch (next) {
    final int n => n,
    final Object e => throw e,
    null => 0,
  };

  void set(int value) => emit(value);
}

void main() {
  test('começa carregando (sem dado e sem erro)', () {
    final store = _NumberStore();
    expect((store.data, store.error), (null, null));
  });

  test('load guarda dado e avisa', () async {
    final store = _NumberStore()..next = 7;
    var notified = 0;
    store.addListener(() => notified++);

    await store.load();

    expect(store.data, 7);
    expect(store.error, isNull);
    expect(notified, 1);
  });

  test('falha guarda erro e mantém dado anterior', () async {
    final store = _NumberStore()..next = 1;
    await store.load();

    store.next = Exception('rede');
    await store.load();

    expect(store.data, 1);
    expect(store.error, isA<Exception>());
  });

  test('novo load limpa o erro antes de buscar', () async {
    final store = _NumberStore()..next = Exception('rede');
    await store.load();
    final errors = <Object?>[];
    store.addListener(() => errors.add(store.error));

    store.next = 2;
    await store.load();

    expect(errors, [null, null]);
    expect(store.data, 2);
  });

  test('erro de código também vai pro estado e sobe', () async {
    final store = _NumberStore()..next = StateError('bug');

    await expectLater(store.load(), throwsStateError);
    expect(store.error, isA<StateError>());
  });

  test('emit troca o dado e avisa', () {
    final store = _NumberStore();
    var notified = 0;
    store.addListener(() => notified++);

    store.set(3);

    expect(store.data, 3);
    expect(notified, 1);
  });

  group('StoreGroup', () {
    test('pronto só com todos carregados', () async {
      final a = _NumberStore();
      final b = _NumberStore();
      await a.load();

      expect([a, b].isReady, isFalse);
      await b.load();
      expect([a, b].isReady, isTrue);
    });

    test('error = primeiro erro; retry recarrega só quem falhou', () async {
      final ok = _NumberStore()..next = 1;
      final failed = _NumberStore()..next = Exception('rede');
      await ok.load();
      await failed.load();
      final stores = [ok, failed];
      expect(stores.error, same(failed.error));

      ok.next = 99;
      failed.next = 2;
      stores.retry();
      await Future<void>.delayed(Duration.zero);

      expect(stores.error, isNull);
      expect((ok.data, failed.data), (1, 2));
    });
  });
}
