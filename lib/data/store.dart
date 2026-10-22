import 'package:flutter/foundation.dart';

/// Estado compartilhado de um recurso da API.
/// Tela escuta com `ListenableBuilder` e lê `data` / `error`.
/// `data` e `error` nulos = carregando.
abstract class Store<T extends Object> extends ChangeNotifier {
  T? _data;
  Object? _error;

  T? get data => _data;
  Object? get error => _error;

  /// Busca na API. Falha fica em `error`; dado anterior é mantido.
  Future<void> load() async {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
    try {
      _data = await fetch();
    } catch (e) {
      _error = e;
      // Erro de código (ex.: JSON fora do contrato) também sobe pro log.
      if (e is! Exception) rethrow;
    } finally {
      notifyListeners();
    }
  }

  @protected
  Future<T> fetch();

  /// Troca o dado depois de uma ação local (adicionar, remover).
  @protected
  void emit(T data) {
    _data = data;
    notifyListeners();
  }
}

/// Vários stores de uma mesma tela.
extension StoreGroup on List<Store> {
  bool get isReady => every((s) => s.data != null);

  Object? get error => map((s) => s.error).nonNulls.firstOrNull;

  /// Recarrega só os que falharam.
  void retry() {
    for (final s in where((s) => s.error != null)) {
      s.load();
    }
  }
}
