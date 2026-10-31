import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:tagarela/data/models/models.dart';

class AppEnvironment {
  const AppEnvironment({
    required this.apiUrl,
    required this.googleIosClientId,
    required this.appleClientId,
  });

  factory AppEnvironment.fromJson(Json json) => AppEnvironment(
    apiUrl: _apiUrlOverride.isEmpty
        ? json['API_URL'] as String
        : _apiUrlOverride,
    googleIosClientId: json['GOOGLE_IOS_CLIENT_ID'] as String,
    appleClientId: json['APPLE_CLIENT_ID'] as String,
  );

  static const _apiUrlOverride = String.fromEnvironment('API_URL');

  static Future<AppEnvironment> load() async {
    final content = await rootBundle.loadString('env/$appFlavor.json');
    return AppEnvironment.fromJson(jsonDecode(content) as Json);
  }

  final String apiUrl;
  final String googleIosClientId;
  final String appleClientId;
}
