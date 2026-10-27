import 'package:tagarela/data/models/models.dart';

const _rows = {
  CourseLanguage.en: ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'],
  CourseLanguage.es: ['qwertyuiop', 'asdfghjklñ', 'zxcvbnm'],
  CourseLanguage.pt: ['qwertyuiop', 'asdfghjklç', 'zxcvbnm'],
};

const _accents = {
  CourseLanguage.en: '',
  CourseLanguage.es: 'áéíóúü',
  CourseLanguage.pt: 'áâãàéêíóôõú',
};

final _letter = RegExp(r'\p{L}', unicode: true);

List<String> keyboardRows(CourseLanguage language, String answer) {
  final rows = _rows[language]!;
  final accents = _accents[language]!;
  final known = '${rows.join()}$accents';
  final missing = {
    for (final char in answer.toLowerCase().split(''))
      if (_letter.hasMatch(char) && !known.contains(char)) char,
  }.join();
  final top = '$accents$missing';
  return [if (top.isNotEmpty) top, ...rows];
}
