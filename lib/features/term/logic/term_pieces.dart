const _letterTiles = 8;
const _vowels = 'aeiouáéíóúàâêôãõü';
const _onsets = {
  'bl',
  'br',
  'ch',
  'cl',
  'cr',
  'dr',
  'fl',
  'fr',
  'gl',
  'gr',
  'lh',
  'nh',
  'ph',
  'pl',
  'pr',
  'sh',
  'th',
  'tr',
  'vr',
  'wh',
  'wr',
};

({List<String> pieces, bool joined}) termPieces(String text) {
  final words = text.trim().split(RegExp(r'\s+'));
  if (words.length > 1) return (pieces: words, joined: false);
  final parts = words.single.split(RegExp(r'(?<=-)'));
  if (parts.length > 1) return (pieces: parts, joined: true);
  final letters = words.single.runes.map(String.fromCharCode).toList();
  if (letters.length <= _letterTiles) return (pieces: letters, joined: true);
  return (pieces: _chunks(letters), joined: true);
}

List<String> _chunks(List<String> letters) {
  final n = letters.length;
  final count = (n / 3.5).round().clamp(3, 5);
  bool vowel(int i) => _vowels.contains(letters[i].toLowerCase());
  bool onset(int i) =>
      _onsets.contains('${letters[i]}${letters[i + 1]}'.toLowerCase());
  double cost(int i) {
    if (vowel(i - 1) && !vowel(i) && (vowel(i + 1) || onset(i))) return 0;
    if (!vowel(i - 1) && !vowel(i) && vowel(i - 2) && vowel(i + 1)) {
      return onset(i - 1) ? 2 : 0;
    }
    if (vowel(i - 1) && !vowel(i)) return 0.5;
    return 2;
  }

  final cuts = <int>[];
  for (var k = 1; k < count; k++) {
    final ideal = n * k / count;
    final from = cuts.isEmpty ? 2 : cuts.last + 2;
    int? best;
    for (var i = from; i <= n - 2; i++) {
      final score = (i - ideal).abs() + cost(i);
      if (best == null || score < (best - ideal).abs() + cost(best)) best = i;
    }
    if (best != null) cuts.add(best);
  }
  return [
    for (var k = 0; k <= cuts.length; k++)
      letters
          .sublist(k == 0 ? 0 : cuts[k - 1], k == cuts.length ? n : cuts[k])
          .join(),
  ];
}
