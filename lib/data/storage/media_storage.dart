import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:tagarela/data/models/models.dart';

class MediaStorage {
  MediaStorage([Future<Directory> Function()? root])
    : _root = root ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _root;

  Future<String> save(String id, CaptureSource source, File file) async {
    final extension = file.path.split('.').last.toLowerCase();
    final path = 'captures/${source.name}/$id.$extension';
    final target = File('${(await _root()).path}/$path');
    await target.parent.create(recursive: true);
    await file.copy(target.path);
    return path;
  }

  Future<File?> find(String path) async {
    final file = File('${(await _root()).path}/$path');
    return await file.exists() ? file : null;
  }

  Future<void> delete(String path) async => (await find(path))?.delete();
}
