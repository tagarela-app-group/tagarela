import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

void main() {
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
