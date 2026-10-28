import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/shared/logic/group_style.dart';

TermGroup _group(GroupIcon? icon) => TermGroup(
  id: '1',
  name: 'Grupo',
  icon: icon,
  color: GroupColor.sky,
  terms: const [],
);

void main() {
  test('48 ícones, cada um com desenho próprio', () {
    expect(GroupIcon.values, hasLength(48));
    expect(GroupIcon.values.map((i) => i.glyph).toSet(), hasLength(48));
  });

  test('ícone desconhecido da API usa o do vocabulário', () {
    expect(_group(null).glyph, AppIcons.vocabulary);
    expect(_group(GroupIcon.paw).glyph, AppIcons.paw);
  });

  test('cada cor do grupo tem um acento e volta pra mesma cor', () {
    expect(
      GroupColor.values.map((c) => c.accent),
      unorderedEquals(AppAccent.values),
    );
    for (final color in GroupColor.values) {
      expect(GroupColorAccent.of(color.accent), color);
    }
    expect(_group(null).accent, AppAccent.sky);
  });
}
