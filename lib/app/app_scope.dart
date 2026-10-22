import 'package:flutter/widgets.dart';

import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/services/home_service.dart';
import 'package:tagarela/data/services/inbox_service.dart';
import 'package:tagarela/data/services/user_service.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/data/stores/inbox_store.dart';
import 'package:tagarela/data/stores/user_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

/// Stores do app, acessíveis de qualquer tela via `AppScope.of(context)`.
/// Vivem o app inteiro; cada tela escuta só o que usa.
class AppScope extends InheritedWidget {
  AppScope({super.key, required ApiClient api, required super.child})
    : user = UserStore(UserService(api)),
      home = HomeStore(HomeService(api)),
      vocabulary = VocabularyStore(VocabularyService(api)) {
    inbox = InboxStore(InboxService(api), vocabulary: vocabulary);
  }

  final UserStore user;
  final HomeStore home;
  final VocabularyStore vocabulary;
  late final InboxStore inbox;

  static AppScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  /// Depois do login.
  Future<void> loadAll() =>
      Future.wait([user.load(), home.load(), vocabulary.load(), inbox.load()]);

  // Os stores avisam as telas; o escopo em si nunca muda.
  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
