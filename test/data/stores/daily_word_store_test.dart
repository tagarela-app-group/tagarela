import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_daily_word_api.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('virada do dia', () {
    late DateTime now;
    late FakeDailyWord fake;

    setUp(() async {
      now = DateTime(2026, 11, 1, 23, 50);
      fake = fakeDailyWord(FakeDailyWordApi(word: hangryJson), () => now);
      await fake.store.load();
      fake.api.word = {...hangryJson, 'text': 'snack'};
    });

    test('no mesmo dia mantém a palavra sem chamar a API', () async {
      final calls = fake.api.calls.length;
      now = DateTime(2026, 11, 1, 23, 59);

      await fake.store.refreshDay();

      expect(fake.store.data?.text, 'hangry');
      expect(fake.api.calls, hasLength(calls));
    });

    test('depois da meia-noite busca a palavra nova', () async {
      now = DateTime(2026, 11, 2, 0, 1);

      await fake.store.refreshDay();

      expect(fake.store.data?.text, 'snack');
    });

    test(
      'sem rede a palavra velha some e volta na próxima tentativa',
      () async {
        now = DateTime(2026, 11, 2, 8);
        fake.api.offline = true;

        await fake.store.refreshDay();

        expect(fake.store.data, isNull);

        fake.api.offline = false;
        await fake.store.refreshDay();

        expect(fake.store.data?.text, 'snack');
      },
    );
  });

  test('sem palavra da API o store fica sem dado e com erro', () async {
    final fake = fakeDailyWord();

    await fake.store.load();

    expect(fake.store.data, isNull);
    expect(fake.store.error, isNotNull);
  });

  test('guardar traz o termo e recarrega o vocabulário', () async {
    final fake = fakeDailyWord(FakeDailyWordApi(word: hangryJson));
    await fake.store.load();
    expect(fake.store.data?.term, isNull);

    await fake.store.save();

    expect(fake.store.data?.term?.id, 't-hangry');
    expect(fake.saved, ['recarregou']);
  });

  test('guardar sem rede não recarrega e mantém a palavra', () async {
    final fake = fakeDailyWord(FakeDailyWordApi(word: hangryJson));
    await fake.store.load();
    fake.api.offline = true;

    await expectLater(fake.store.save(), throwsException);

    expect(fake.store.data?.text, 'hangry');
    expect(fake.saved, isEmpty);
  });

  test('trocar de curso apaga a palavra antiga na hora', () async {
    final fake = fakeDailyWord(FakeDailyWordApi(word: hangryJson));
    final app = fakeDependencies(dailyWord: fake.store);
    await fake.store.load();
    fake.api.word = null;

    await app.session.loadStudy();

    expect(fake.store.data, isNull);
  });

  test('a palavra que falha não impede o resto de carregar', () async {
    final app = fakeDependencies();

    await app.session.loadAll();

    expect(app.dailyWord.data, isNull);
    expect(app.vocabulary.data, isNotNull);
    expect(app.practice.data, isNotNull);
  });

  test('sair limpa a palavra', () async {
    final fake = fakeDailyWord(FakeDailyWordApi(word: hangryJson));
    final app = fakeDependencies(dailyWord: fake.store);
    await fake.store.load();

    await app.session.signOut();

    expect(fake.store.data, isNull);
  });
}
