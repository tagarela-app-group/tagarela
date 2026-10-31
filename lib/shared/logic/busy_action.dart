import 'package:flutter/widgets.dart';

mixin BusyAction<T extends StatefulWidget> on State<T> {
  bool busy = false;
  String? failure;

  Future<void> runAction(
    Future<void> Function() action, {
    required String Function(Exception error) failureOf,
  }) async {
    setState(() {
      busy = true;
      failure = null;
    });
    try {
      await action();
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        busy = false;
        failure = failureOf(error);
      });
    }
  }
}
