import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/shared/logic/card_text.dart';

void main() {
  group('stressedParts', () {
    test('marca a sílaba depois do acento tônico', () {
      expect(stressedParts('/ɑːn ðə ˈfens/'), [
        (text: '/ɑːn ðə ˈ', marked: false),
        (text: 'fens', marked: true),
        (text: '/', marked: false),
      ]);
    });

    test('mais de uma tônica e secundária sem destaque', () {
      expect(stressedParts('/ˈmaɪnd ðə ˌɡæp/'), [
        (text: '/ˈ', marked: false),
        (text: 'maɪnd', marked: true),
        (text: ' ðə ˌɡæp/', marked: false),
      ]);
    });

    test('sem acento fica tudo igual', () {
      expect(stressedParts('/rʌn/'), [(text: '/rʌn/', marked: false)]);
    });
  });

  group('phrasePieces', () {
    test('o termo inteiro vira a peça destacada', () {
      expect(phrasePieces('sit on the fence', 'on the fence'), [
        (text: 'sit', marked: false),
        (text: 'on the fence', marked: true),
      ]);
      expect(phrasePieces('On the fence about', 'on the fence'), [
        (text: 'On the fence', marked: true),
        (text: 'about', marked: false),
      ]);
    });

    test('sem o termo inteiro, destaca o maior pedaço que aparece', () {
      expect(phrasePieces('get off the fence', 'on the fence'), [
        (text: 'get off', marked: false),
        (text: 'the fence', marked: true),
      ]);
    });

    test('palavra curta solta não conta como pedaço', () {
      expect(phrasePieces('sit on it', 'on the fence'), [
        (text: 'sit on it', marked: false),
      ]);
    });

    test('só casa palavra inteira', () {
      expect(phrasePieces('running late', 'run'), [
        (text: 'running late', marked: false),
      ]);
      expect(phrasePieces('run a business', 'run'), [
        (text: 'run', marked: true),
        (text: 'a business', marked: false),
      ]);
    });
  });
}
