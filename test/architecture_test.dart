import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _app = 'package:tagarela/app/';
const _scope = 'package:tagarela/app/app_scope.dart';
const _features = 'package:tagarela/features/';
const _shared = 'package:tagarela/shared/';
const _designSystem = 'package:tagarela/design_system/';
const _data = 'package:tagarela/data/';

const _forbidden = <String, List<String>>{
  'data/': [
    _app,
    _features,
    _shared,
    _designSystem,
    'package:flutter/material.dart',
    'package:flutter/widgets.dart',
    'package:flutter/cupertino.dart',
  ],
  'data/models/': [
    '${_data}services/',
    '${_data}stores/',
    '${_data}storage/',
    '${_data}device/',
    '${_data}sync/',
  ],
  'design_system/': [_app, _features, _shared, _data],
  'shared/': [_app, _features],
  'features/': ['${_data}services/', '${_data}storage/', '${_data}sync/'],
};

const _allowed = <String, List<String>>{
  'shared/': [_scope],
};

final _import = RegExp(r"^import '([^']+)'", multiLine: true);
final _feature = RegExp(r'^features/(\w+)/');
final _otherFeature = RegExp(r'^package:tagarela/features/(\w+)/(.+)$');
final _entry = RegExp(r'^(\w+_page|modals/\w+_modal)\.dart$');

bool breaksLayer(String file, String target) =>
    !_matches(_allowed, file, target) && _matches(_forbidden, file, target);

bool _matches(Map<String, List<String>> rules, String file, String target) =>
    rules.entries.any(
      (rule) => file.startsWith(rule.key) && rule.value.any(target.startsWith),
    );

bool crossesFeature(String file, String target) {
  final from = _feature.firstMatch(file)?.group(1);
  final to = _otherFeature.firstMatch(target);
  if (from == null || to == null || to.group(1) == from) return false;
  return !_entry.hasMatch(to.group(2)!);
}

Iterable<(String, String)> _imports() sync* {
  for (final file in Directory('lib').listSync(recursive: true)) {
    if (file is! File || !file.path.endsWith('.dart')) continue;
    final path = file.path.replaceAll(r'\', '/').replaceFirst('lib/', '');
    for (final match in _import.allMatches(file.readAsStringSync())) {
      yield (path, match.group(1)!);
    }
  }
}

void main() {
  test('dependências só descem', () {
    expect([
      for (final (file, target) in _imports())
        if (breaksLayer(file, target)) '$file -> $target',
    ], isEmpty);
  });

  test('feature só abre página ou modal de outra', () {
    expect([
      for (final (file, target) in _imports())
        if (crossesFeature(file, target)) '$file -> $target',
    ], isEmpty);
  });

  test('as regras pegam import proibido', () {
    expect(breaksLayer('data/models/x.dart', '${_designSystem}x.dart'), isTrue);
    expect(breaksLayer('shared/x.dart', '${_app}home_shell.dart'), isTrue);
    expect(breaksLayer('shared/x.dart', _scope), isFalse);
    expect(breaksLayer('features/a/x.dart', '${_data}models/x.dart'), isFalse);
    expect(
      crossesFeature('features/a/x.dart', '${_features}b/w/y.dart'),
      isTrue,
    );
    expect(
      crossesFeature('features/a/x.dart', '${_features}b/y_page.dart'),
      isFalse,
    );
    expect(
      crossesFeature('features/a/x.dart', '${_features}b/modals/y_modal.dart'),
      isFalse,
    );
  });
}
