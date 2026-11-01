import 'package:tagarela/data/models/models.dart';

enum TermFilter {
  all,
  ungrouped,
  learning,
  mastered;

  bool accepts(TermEntry entry) => switch (this) {
    TermFilter.all => true,
    TermFilter.ungrouped => entry.group == null,
    TermFilter.learning => entry.term.status == TermStatus.learning,
    TermFilter.mastered => entry.term.status == TermStatus.mastered,
  };
}
