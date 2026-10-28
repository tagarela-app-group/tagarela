class RejectedException implements Exception {
  const RejectedException([this.fields = const {}]);

  final Map<String, String> fields;

  @override
  String toString() => 'RejectedException: $fields';
}

class ServerException implements Exception {
  const ServerException();

  @override
  String toString() => 'ServerException';
}
