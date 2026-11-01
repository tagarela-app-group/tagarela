import 'package:flutter/foundation.dart';

import 'package:tagarela/data/services/api_client.dart';

abstract class Store<T extends Object> extends ChangeNotifier {
  T? _data;
  Object? _error;
  int _started = 0;
  int _applied = 0;

  T? get data => _data;
  Object? get error => _error;

  Future<void> load() async {
    final ticket = ++_started;
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
    try {
      final fetched = await fetch();
      if (_claim(ticket)) {
        _data = fetched;
        _error = null;
      }
    } catch (e) {
      if (_claim(ticket)) _error = e;
      if (e is! Exception) rethrow;
    } finally {
      notifyListeners();
    }
  }

  bool _claim(int ticket) {
    if (ticket < _applied) return false;
    _applied = ticket;
    return true;
  }

  @protected
  Future<T> fetch();

  @protected
  Future<R> guard<R>(Future<R> Function() request) async {
    try {
      return await request();
    } on ApiException catch (e) {
      throw e.forApp;
    }
  }

  void clear() {
    _data = null;
    _error = null;
    notifyListeners();
  }

  @protected
  void emit(T data) {
    _data = data;
    notifyListeners();
  }
}

extension StoreGroup on List<Store> {
  bool get isReady => every((s) => s.data != null);

  Object? get error => map((s) => s.error).nonNulls.firstOrNull;

  void retry() {
    for (final s in where((s) => s.error != null)) {
      s.load();
    }
  }
}
