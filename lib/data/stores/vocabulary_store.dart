import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/store.dart';

class VocabularyStore extends Store<List<TermGroup>> {
  VocabularyStore([this._groups = const []]);

  final List<TermGroup> _groups;

  @override
  Future<List<TermGroup>> fetch() async => _groups;
}
