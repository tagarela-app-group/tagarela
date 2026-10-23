import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/store.dart';

typedef HomeData = ({Stats stats, WordOfDay? wordOfDay});

class HomeStore extends Store<HomeData> {
  HomeStore([this._data = empty]);

  static const HomeData empty = (
    stats: Stats(weekGain: 0, reviewCount: 0),
    wordOfDay: null,
  );

  final HomeData _data;

  @override
  Future<HomeData> fetch() async => _data;
}
