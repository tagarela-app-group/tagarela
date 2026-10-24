import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tagarela/data/speech_model.dart';

class ModelStorage {
  ModelStorage({
    Future<Directory> Function()? root,
    HttpClient Function()? client,
  }) : _root = root ?? getApplicationSupportDirectory,
       _client = client ?? HttpClient.new;

  static const _complete = '.complete';
  static const _connectTimeout = Duration(seconds: 15);
  static const _idleTimeout = Duration(seconds: 30);

  final Future<Directory> Function() _root;
  final HttpClient Function() _client;

  Future<Directory> _models() async =>
      Directory('${(await _root()).path}/models');

  Future<Directory> _folder(SpeechModel model) async =>
      Directory('${(await _models()).path}/${model.id}');

  Future<String?> installed(SpeechModel model) async {
    final folder = await _folder(model);
    return await File('${folder.path}/$_complete').exists()
        ? folder.path
        : null;
  }

  Stream<double> download(SpeechModel model) async* {
    final folder = await _folder(model);
    await folder.create(recursive: true);
    final client = _client()..connectionTimeout = _connectTimeout;
    var received = 0;
    try {
      for (final file in model.files) {
        final target = File('${folder.path}/${file.name}');
        if (await target.exists() && await target.length() == file.size) {
          received += file.size;
          yield received / model.size;
          continue;
        }
        final response = await (await client.getUrl(model.url(file))).close();
        if (response.statusCode != HttpStatus.ok) {
          throw HttpException(
            'status ${response.statusCode}',
            uri: model.url(file),
          );
        }
        final part = File('${target.path}.part');
        final sink = part.openWrite();
        final digest = _DigestSink();
        final hash = sha256.startChunkedConversion(digest);
        try {
          await for (final chunk in response.timeout(_idleTimeout)) {
            sink.add(chunk);
            hash.add(chunk);
            received += chunk.length;
            yield received / model.size;
          }
        } finally {
          await sink.close();
        }
        hash.close();
        if (digest.value.toString() != file.sha256) {
          await part.delete();
          throw FileSystemException('arquivo corrompido', target.path);
        }
        await part.rename(target.path);
      }
      await File('${folder.path}/$_complete').writeAsString('');
      await _keepOnly(model);
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _keepOnly(SpeechModel model) async {
    await for (final entry in (await _models()).list()) {
      final name = entry.path.split(RegExp(r'[/\\]')).last;
      if (entry is Directory && name != model.id) {
        await entry.delete(recursive: true);
      }
    }
  }
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
