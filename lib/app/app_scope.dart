import 'package:flutter/widgets.dart';

import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/services/home_service.dart';
import 'package:tagarela/data/services/inbox_service.dart';
import 'package:tagarela/data/services/vocabulary_service.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/data/stores/home_store.dart';
import 'package:tagarela/data/stores/inbox_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';

class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    required ApiClient api,
    required this.auth,
    required super.child,
  }) : home = HomeStore(HomeService(api)),
       vocabulary = VocabularyStore(VocabularyService(api)) {
    inbox = InboxStore(InboxService(api), vocabulary: vocabulary);
  }

  final AuthStore auth;
  final HomeStore home;
  final VocabularyStore vocabulary;
  late final InboxStore inbox;

  static AppScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  Future<void> loadAll() =>
      Future.wait([home.load(), vocabulary.load(), inbox.load()]);

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
