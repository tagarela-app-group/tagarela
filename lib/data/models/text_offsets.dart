int codePointOffset(String text, int codeUnits) =>
    text.substring(0, codeUnits).runes.length;

int codeUnitOffset(String text, int codePoints) {
  var units = 0;
  var count = 0;
  for (final rune in text.runes) {
    if (count == codePoints) break;
    units += rune > 0xFFFF ? 2 : 1;
    count++;
  }
  return units;
}
