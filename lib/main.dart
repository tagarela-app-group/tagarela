import 'package:flutter/material.dart';

import 'package:tagarela/app/app.dart';
import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/data/social_sign_in.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/token_storage.dart';

void main() => runApp(
  AppScope(
    api: ApiClient(),
    auth: AuthStore(
      AuthService(ApiClient(baseUrl: ApiClient.authBaseUrl)),
      TokenStorage(),
      SocialSignIn(),
    ),
    child: const TagarelaApp(),
  ),
);
