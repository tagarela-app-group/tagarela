import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_environment.dart';
import 'package:tagarela/data/models/models.dart';

AppEnvironment _read(String name) => AppEnvironment.fromJson(
  jsonDecode(File('env/$name.json').readAsStringSync()) as Json,
);

void main() {
  test('prd só fala com a API por https', () {
    expect(Uri.parse(_read('prd').apiUrl).scheme, 'https');
  });

  test('dsv não aponta pra API de prd', () {
    expect(_read('dsv').apiUrl, isNot(_read('prd').apiUrl));
  });
}
