import 'package:flutter/material.dart';

import 'package:tagarela/app/app.dart';
import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/api_client.dart';

void main() => runApp(AppScope(api: ApiClient(), child: const TagarelaApp()));
