import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class TextCaptureSheet extends StatefulWidget {
  const TextCaptureSheet({super.key});

  static const maxLength = 500;

  @override
  State<TextCaptureSheet> createState() => _TextCaptureSheetState();
}

class _TextCaptureSheetState extends State<TextCaptureSheet> {
  final _text = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final capture = await AppScope.of(
      context,
    ).captures.createText(_text.text.trim());
    if (mounted) Navigator.pop(context, capture);
  }

  @override
  Widget build(BuildContext context) => AppSheet(
    icon: AppIcons.text,
    accent: AppAccent.violet,
    title: context.l10n.typeText,
    subtitle: context.l10n.typeTextHint,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s4,
      children: [
        AppTextField(
          label: context.l10n.textCaptureLabel,
          helperText: context.l10n.textCaptureHelper,
          controller: _text,
          lines: 4,
          maxLength: TextCaptureSheet.maxLength,
          autofocus: true,
        ),
        ListenableBuilder(
          listenable: _text,
          builder: (context, _) => AppButton(
            label: context.l10n.saveToInbox,
            expand: true,
            loading: _saving,
            onPressed: _text.text.trim().isEmpty ? null : _save,
          ),
        ),
      ],
    ),
  );
}
