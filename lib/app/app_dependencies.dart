import 'package:tagarela/app/app_environment.dart';
import 'package:tagarela/app/app_session.dart';
import 'package:tagarela/data/device/audio_playback.dart';
import 'package:tagarela/data/device/capture_device.dart';
import 'package:tagarela/data/device/social_sign_in.dart';
import 'package:tagarela/data/device/text_extractor.dart';
import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/services/account_service.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/services/course_service.dart';
import 'package:tagarela/data/services/daily_word_service.dart';
import 'package:tagarela/data/services/exercise_service.dart';
import 'package:tagarela/data/services/review_service.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/storage/database.dart';
import 'package:tagarela/data/storage/media_storage.dart';
import 'package:tagarela/data/storage/model_storage.dart';
import 'package:tagarela/data/storage/preferences.dart';
import 'package:tagarela/data/storage/token_storage.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/data/stores/course_store.dart';
import 'package:tagarela/data/stores/daily_word_store.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/data/stores/practice_store.dart';
import 'package:tagarela/data/stores/speech_model_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

class AppDependencies {
  AppDependencies({
    required this.auth,
    required this.courses,
    required this.captures,
    required this.playback,
    required this.device,
    required this.speech,
    required this.vocabulary,
    required this.practice,
    required this.dailyWord,
    required this.language,
    required this.voice,
  });

  factory AppDependencies.live(AppEnvironment environment) {
    final models = ModelStorage();
    late final AuthStore auth;
    final api = ApiClient(
      baseUrl: environment.apiUrl,
      accessToken: ({renew = false}) => auth.accessToken(renew: renew),
    );
    auth = AuthStore(
      AuthService(ApiClient(baseUrl: environment.apiUrl)),
      AccountService(api),
      TokenStorage(),
      SocialSignIn(
        googleIosClientId: environment.googleIosClientId,
        appleClientId: environment.appleClientId,
      ),
    );
    final courses = CourseStore(CourseService(api));
    final vocabulary = VocabularyStore(VocabularyService(api));
    final db = AppDatabase();
    String? owner() => auth.user?.email;
    return AppDependencies(
      auth: auth,
      courses: courses,
      captures: CaptureStore(
        CaptureService(api),
        db,
        MediaStorage(),
        owner: owner,
        course: () => courses.active?.id,
        extractor: TextExtractor(models),
        onConfirmed: vocabulary.load,
      ),
      playback: AudioPlayback(),
      device: CaptureDevice(),
      speech: SpeechModelStore(models),
      vocabulary: vocabulary,
      practice: PracticeStore(
        ReviewService(api),
        ExerciseService(api),
        db,
        owner: owner,
      ),
      dailyWord: DailyWordStore(
        DailyWordService(api),
        onSaved: vocabulary.load,
      ),
      language: LanguageStore(Preferences(), courses),
      voice: Voice(),
    );
  }

  final AuthStore auth;
  final CourseStore courses;
  final CaptureStore captures;
  final AudioPlayback playback;
  final CaptureDevice device;
  final SpeechModelStore speech;
  final VocabularyStore vocabulary;
  final PracticeStore practice;
  final DailyWordStore dailyWord;
  final LanguageStore language;
  final Voice voice;

  late final session = AppSession(this);
}
