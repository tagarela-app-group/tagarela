import 'package:flutter/material.dart';

import 'package:tagarela/app/app.dart';
import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/audio_playback.dart';
import 'package:tagarela/data/capture_device.dart';
import 'package:tagarela/data/database.dart';
import 'package:tagarela/data/media_storage.dart';
import 'package:tagarela/data/model_storage.dart';
import 'package:tagarela/data/preferences.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/services/course_service.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/social_sign_in.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/data/stores/course_store.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';
import 'package:tagarela/data/text_extractor.dart';
import 'package:tagarela/data/token_storage.dart';
import 'package:tagarela/data/voice.dart';

void main() {
  final models = ModelStorage();
  final auth = AuthStore(
    AuthService(ApiClient()),
    TokenStorage(),
    SocialSignIn(),
  );
  final api = ApiClient(accessToken: auth.accessToken);
  final vocabulary = VocabularyStore(VocabularyService(api));
  final courses = CourseStore(CourseService(api));
  runApp(
    AppScope(
      auth: auth,
      courses: courses,
      captures: CaptureStore(
        CaptureService(api),
        AppDatabase(),
        MediaStorage(),
        owner: () => auth.user?.email,
        course: () => courses.active?.id,
        extractor: TextExtractor(models),
        onConfirmed: vocabulary.load,
      ),
      vocabulary: vocabulary,
      language: LanguageStore(Preferences()),
      voice: Voice(),
      playback: AudioPlayback(),
      device: CaptureDevice(),
      speech: SpeechModelStore(models),
      child: const TagarelaApp(),
    ),
  );
}
