import 'package:tagarela/data/device/text_extractor.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

TitledText captureFailure(AppLocalizations l10n, Capture capture) {
  final photo = capture.source == CaptureSource.photo;
  return switch (capture.error) {
    final e when e == ExtractionError.noText.code => TitledText(
      title: photo ? l10n.noTextInPhoto : l10n.noSpeech,
      text: photo ? l10n.noTextInPhotoHint : l10n.noSpeechHint,
    ),
    _ => TitledText(
      title: l10n.processFailedTitle,
      text: l10n.processFailedHint,
    ),
  };
}
