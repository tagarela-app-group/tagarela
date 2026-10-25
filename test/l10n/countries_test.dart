import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/l10n/countries.dart';

import '../helpers/l10n.dart';

void main() {
  test('250 países, os mesmos da API', () {
    final codes = pt.countries().map((c) => c.code).toSet();

    expect(codes, hasLength(250));
    expect(codes, containsAll(['BR', 'US', 'ES', 'PT', 'XK', 'AR', 'MX']));
    expect(codes.every((c) => RegExp(r'^[A-Z]{2}$').hasMatch(c)), isTrue);
  });

  test('nome no idioma do app', () {
    expect(pt.countryName('DE'), 'Alemanha');
    expect(en.countryName('DE'), 'Germany');
    expect(es.countryName('DE'), 'Alemania');
    expect(pt.countryName('ZZ'), isNull);
  });

  test('ordem alfabética ignora acento', () {
    final names = pt.countries().map((c) => c.name).toList();

    expect(names.first, 'Afeganistão');
    expect(names.indexOf('Áustria'), lessThan(names.indexOf('Azerbaijão')));
  });

  test('busca sem acento e sem caixa', () {
    expect(foldText('São Tomé e Príncipe'), 'sao tome e principe');
    expect(foldText('Côte d’Ivoire'), "cote d'ivoire");
    expect(foldText('MÉXICO'), 'mexico');
  });
}
