typedef Part = ({String text, bool marked});

const _stressMarks = {'ˈ'};
const _syllableEnds = {' ', '/', '[', ']', 'ˈ', 'ˌ', '.'};

List<Part> stressedParts(String phonetic) {
  final parts = <Part>[];
  final buffer = StringBuffer();
  var stressed = false;
  void flush() {
    if (buffer.isEmpty) return;
    parts.add((text: buffer.toString(), marked: stressed));
    buffer.clear();
  }

  for (final char in phonetic.split('')) {
    if (stressed && _syllableEnds.contains(char)) {
      flush();
      stressed = false;
    }
    buffer.write(char);
    if (_stressMarks.contains(char)) {
      flush();
      stressed = true;
    }
  }
  flush();
  return parts;
}

List<Part> phrasePieces(String phrase, String term) {
  final words = term.trim().split(RegExp(r'\s+'));
  for (var size = words.length; size > 0; size--) {
    for (var start = 0; start + size <= words.length; start++) {
      final needle = words.sublist(start, start + size).join(' ');
      if (size == 1 && words.length > 1 && needle.length <= 3) continue;
      final match = RegExp(
        r'(?<![\p{L}\p{N}])' + RegExp.escape(needle) + r'(?![\p{L}\p{N}])',
        caseSensitive: false,
        unicode: true,
      ).firstMatch(phrase);
      if (match == null) continue;
      return [
        for (final (text, marked) in [
          (phrase.substring(0, match.start).trim(), false),
          (match.group(0)!, true),
          (phrase.substring(match.end).trim(), false),
        ])
          if (text.isNotEmpty) (text: text, marked: marked),
      ];
    }
  }
  return [(text: phrase, marked: false)];
}
