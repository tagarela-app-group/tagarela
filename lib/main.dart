import 'package:flutter/material.dart';

import 'package:tagarela/app/app.dart';
import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/audio_playback.dart';
import 'package:tagarela/data/capture_device.dart';
import 'package:tagarela/data/database.dart';
import 'package:tagarela/data/media_storage.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/social_sign_in.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/data/token_storage.dart';

void main() {
  final auth = AuthStore(
    AuthService(ApiClient()),
    TokenStorage(),
    SocialSignIn(),
  );
  runApp(
    AppScope(
      auth: auth,
      captures: CaptureStore(
        CaptureService(ApiClient(accessToken: auth.accessToken)),
        AppDatabase(),
        MediaStorage(),
        owner: () => auth.user?.email,
      ),
      playback: AudioPlayback(),
      device: CaptureDevice(),
      child: const TagarelaApp(),
    ),
  );
}
