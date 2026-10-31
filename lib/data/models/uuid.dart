import 'dart:math';

String newUuid([Random? random]) {
  random ??= Random.secure();
  final bytes = [for (var i = 0; i < 16; i++) random.nextInt(256)];
  bytes[6] = bytes[6] & 0x0f | 0x40;
  bytes[8] = bytes[8] & 0x3f | 0x80;
  final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')];
  return [
    hex.sublist(0, 4),
    hex.sublist(4, 6),
    hex.sublist(6, 8),
    hex.sublist(8, 10),
    hex.sublist(10),
  ].map((part) => part.join()).join('-');
}
