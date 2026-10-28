import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:tagarela/shared/logic/time_ago.dart';

import '../../helpers/l10n.dart';

void main() {
  final now = DateTime(2026, 10, 23, 12);

  setUpAll(initializeDateFormatting);

  test('minutos, horas, ontem e data', () {
    expect(
      timeAgo(pt, now.subtract(const Duration(seconds: 30)), now),
      'agora',
    );
    expect(
      timeAgo(pt, now.subtract(const Duration(minutes: 5)), now),
      'há 5 min',
    );
    expect(timeAgo(pt, now.subtract(const Duration(hours: 2)), now), 'há 2 h');
    expect(timeAgo(pt, DateTime(2026, 10, 22, 23), now), 'ontem');
    expect(timeAgo(pt, DateTime(2026, 10, 3, 8), now), '03/10');
  });

  test('data no formato do idioma', () {
    expect(timeAgo(en, DateTime(2026, 10, 3, 8), now), '10/3');
    expect(timeAgo(es, DateTime(2026, 10, 3, 8), now), '3/10');
    expect(
      timeAgo(en, now.subtract(const Duration(minutes: 5)), now),
      '5 min ago',
    );
  });
}
