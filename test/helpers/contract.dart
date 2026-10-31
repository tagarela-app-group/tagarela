import 'dart:convert';
import 'dart:io';

import 'package:tagarela/data/models/models.dart';

Json contractExample(String name) =>
    jsonDecode(File('test/contract/$name.json').readAsStringSync()) as Json;
