import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_daily_word_api.dart';
import '../../helpers/pump_app.dart';

void main() {
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
