import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/home_service.dart';
import 'package:tagarela/data/store.dart';

typedef HomeData = ({Stats stats, WordOfDay wordOfDay});

class HomeStore extends Store<HomeData> {
  HomeStore(this._service);

  final HomeService _service;

  @override
  Future<HomeData> fetch() async => (
    stats: await _service.fetchStats(),
    wordOfDay: await _service.fetchWordOfDay(),
  );
}
