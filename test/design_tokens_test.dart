import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _layoutLiterals = [
  RegExp(r'\b(?:spacing|runSpacing|gap|fontSize|size|iconSize):\s*[1-9]'),
  RegExp(r'\bcircular\(\s*[1-9]'),
  RegExp(r'\bSizedBox\((?:width|height):\s*[1-9]'),
  RegExp(r'EdgeInsets[\w.]*\((?:[^()]|\([^()]*\))*(?<![\w.])[1-9]'),
];
final _colorLiteral = RegExp(r'\bColor\(0x');

Iterable<String> layoutLiterals(String source) =>
    _layoutLiterals.expand((rule) => rule.allMatches(source)).map((m) => m[0]!);

Iterable<String> colorLiterals(String source) =>
    _colorLiteral.allMatches(source).map((m) => m[0]!);

List<String> _found(
  List<String> roots,
  Iterable<String> Function(String source) literals,
) => [
  for (final root in roots)
    for (final file in Directory(root).listSync(recursive: true))
      if (file is File && file.path.endsWith('.dart'))
        for (final literal in literals(file.readAsStringSync()))
          '${file.path}: $literal',
];

void main() {
  test('reconhece literal e deixa token passar', () {
    for (final literal in const [
      'spacing: 10',
      'fontSize: 15',
      'size: 18',
      'BorderRadius.circular(2)',
      'SizedBox(width: 6)',
      'EdgeInsets.all(14)',
      'EdgeInsets.fromLTRB(0, f(x), 0, 14)',
    ]) {
      expect(layoutLiterals(literal), isNotEmpty, reason: literal);
    }
    for (final token in const [
      'spacing: AppSpacing.s25',
      'size: AppIconSize.md',
      'BorderRadius.circular(AppRadius.xs)',
      'EdgeInsets.fromLTRB(0, AppSpacing.s35, 0, 0)',
    ]) {
      expect(layoutLiterals(token), isEmpty, reason: token);
    }
    expect(colorLiterals('Color(0xDBFFFFFF)'), isNotEmpty);
    expect(colorLiterals('AppPalette.whiteSoft'), isEmpty);
  });

  test('telas não usam espaçamento, raio, fonte nem tamanho soltos', () {
    expect(_found(['lib/features', 'lib/shared'], layoutLiterals), isEmpty);
  });

  test('telas e componentes não usam cor solta', () {
    expect(
      _found([
        'lib/features',
        'lib/shared',
        'lib/design_system/components',
      ], colorLiterals),
      isEmpty,
    );
  });
}
