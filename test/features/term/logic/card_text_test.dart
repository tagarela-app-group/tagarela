import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/features/term/logic/card_text.dart';

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

  group('markedParts', () {
    test('trecho entre asteriscos vira marcado, sem os asteriscos', () {
      expect(markedParts('Em inglês, fica na cerca: *on the fence*.'), [
        (text: 'Em inglês, fica na cerca: ', marked: false),
        (text: 'on the fence', marked: true),
        (text: '.', marked: false),
      ]);
    });

    test('vários trechos e texto sem marca', () {
      expect(markedParts('*a* e *b*'), [
        (text: 'a', marked: true),
        (text: ' e ', marked: false),
        (text: 'b', marked: true),
      ]);
      expect(markedParts('sem marca'), [(text: 'sem marca', marked: false)]);
      expect(markedParts(''), isEmpty);
    });

    test('asterisco sozinho fica como está e par vazio some', () {
      expect(markedParts('5 * 3'), [(text: '5 * 3', marked: false)]);
      expect(markedParts('a ** b'), [
        (text: 'a ', marked: false),
        (text: ' b', marked: false),
      ]);
    });
  });
}
