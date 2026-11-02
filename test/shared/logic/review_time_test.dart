import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/shared/logic/review_time.dart';

import '../../helpers/l10n.dart';

void main() {
  final now = DateTime(2026, 11, 1, 12);

  String back(Duration left) => returnsIn(pt, now.add(left), now);

  test('passou da hora: já pode voltar', () {
    expect(back(Duration.zero), 'Já pode voltar pra revisão');
    expect(back(const Duration(hours: -3)), 'Já pode voltar pra revisão');
  });

  test('menos de um dia conta em horas, arredondando pra cima', () {
    expect(back(const Duration(minutes: 10)), 'Revisão retorna em 1 hora');
    expect(
      back(const Duration(hours: 4, minutes: 1)),
      'Revisão retorna em 5 horas',
    );
  });

  test('a partir de um dia conta em dias', () {
    expect(back(const Duration(hours: 24)), 'Revisão retorna em 1 dia');
    expect(
      back(const Duration(days: 20, hours: 3)),
      'Revisão retorna em 20 dias',
    );
  });

  test('a próxima revisão usa a mesma conta', () {
    expect(
      nextReviewIn(pt, now.add(const Duration(days: 3)), now),
      'A próxima vem em 3 dias',
    );
    expect(
      nextReviewIn(pt, now.add(const Duration(hours: 2)), now),
      'A próxima vem em 2 horas',
    );
  });
}
